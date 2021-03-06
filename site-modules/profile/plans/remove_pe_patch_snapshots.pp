# @summary wrapper plan to remove snapshots created by
# auto_patch_placeholder plan (in turn based on http://bit.ly/PuppetPatchingPlans)
#
# assumes snapshot to removed is named 'pe_patch_snapshot'
# ie: must match the snapshot created by profile::auto_patch_placeholder
#
# At the time of writing the only criteria used to match snapshots to create/delete is the exact name,
# so need to be able to reliably determine the name of the snapshot to delete, it cannot match on wildcard/age etc
#
# @param [String] patch_group
#   Patch group for this plan run (based on pe_patch::patch_group)
# @param [Boolean] noop
#   Flag to enable noop / dry run mode (mainly for debugging). (Default: false)
# @param [Optional[TargetSpec]] snapshot_targets
#   Optional set of targets to run against. The targets specified MUST also belong to patch_group;
#   this is to provide a way to optionally limit snapshot removal to a subset of nodes only
# @param [Boolean] force_vmware
#   Pretend everything is vmware regardless of facter output. Used for debug/testing only. Default: false
# @param [Hash] vsphere_servers
#   Hash of vsphere_servers details - TEMPORARY workaround until plan_hierarchy
#   available (PE 2019.8.5+); once plan_hierarchy setup, uncomment the following
#   line in the plan: $vsphere_servers = lookup('profile::vsphere_details::vsphere_servers')
#   then the vsphere_servers parameter can be removed
#
plan profile::remove_pe_patch_snapshots (
  String $patch_group,
  Boolean $noop = false,
  Optional[TargetSpec] $snapshot_targets = undef,
  Boolean $force_vmware = false,
  Hash $vsphere_servers = { 'vsphere.example.com' =>
                            { 'vsphere_username' => 'user01',
                              'vsphere_password' => 'secret01',
                              'vsphere_insecure' => true,
                            }
  },
){
  # Query PuppetDB to find nodes that have the patch group
  # we don't care if they are blocked or have patches to apply as just removing snapshot
  $all_nodes = puppetdb_query("inventory[certname] { facts.pe_patch.patch_group = '${patch_group}'}")

  # Transform the query output into Targetspec
  $full_list = $all_nodes.map | $r | { $r['certname'] }
  $targets = get_targets($full_list)

  # Start the work
  if $targets.empty {
    # Set the return variables to empty as there is nothing to patch
    $vmware_targets = []
    $snapshot_removed = []
    $snapshot_failed = []
  } else {
    # At the moment skip healthchecks as we just want to remove the snapshots at this point
    # If $snapshot_targets has been provided/is not undef, allow deleting just those provided these
    # targets are actually in patch_group
    if $snapshot_targets {
      $targets_in_group = get_targets($snapshot_targets).filter | $snapshot_target | {
        $snapshot_target in $targets
      }
      if $targets_in_group.empty {
        out::message("Specified targets are not in patch_group ${patch_group}, taking no action")
        $_targets = []
      } else {
        $_targets = $targets_in_group
      }
    } else {
      $_targets = $targets
    }

    if $_targets.empty {
      $vmware_targets = []
      $snapshot_removed = []
      $snapshot_failed = []
    } else {
      # Remove snapshots taken for patching
      # patching::snapshot_vmware takes vsphere details from first target
      # (assumes have same details); to be able to lookup individual details
      # ie: snapshots taken serially not in parallel

      # Use puppetdb_fact plan to collect facts for targets
      # (https://puppet.com/docs/bolt/latest/writing_plans.html#collect-facts-from-puppetdb)
      run_plan('puppetdb_fact', 'targets' => $_targets, '_catch_errors' => true)

      # snapshots apply to vmware targets only
      $vmware_targets = get_targets($_targets).filter | $target | {
        $force_vmware or $target.facts['virtual'] == 'vmware'
      }

      # ignore non-vmware targets for now

      if $vmware_targets.empty {
        out::message("INFO: No vmware targets provided")
        $snapshot_removed = []
        $snapshot_failed = []
      } else {
        # TO-DO: Consider moving variable setting logic to function to avoid duplication
        # assumes vsphere_servers lives in plan_hierarchy to perform lookup
        # outside apply block (static rather than per target)
        # requires PE 2019.8.5+; this would also mean need to duplicate/keep
        # in sync if details needed in standard hiera
        # https://puppet.com/docs/bolt/latest/hiera.html#outside-apply-blocks
        #$vsphere_servers = lookup('profile::vsphere_details::vsphere_servers')

        # At present this assumes all targets in the given patch_group have identical vcenter details
        # (takes details based on first target in $vmware_targets)
        $vsphere_datacenter = get_targets($vmware_targets)[0].facts['vsphere_details']['vsphere_datacenter']
        $vsphere_host = get_targets($vmware_targets)[0].facts['vsphere_details']['vsphere_host']
        if $vsphere_host in $vsphere_servers {
          $vsphere_username = $vsphere_servers[$vsphere_host]['vsphere_username']
          $vsphere_password = $vsphere_servers[$vsphere_host]['vsphere_password']
          $vsphere_insecure = $vsphere_servers[$vsphere_host]['vsphere_insecure']
        } else {
          fail_plan("Unable to find details for vsphere_host ${vsphere_host}")
        }
        $remove_snapshot = run_plan('patching::snapshot_vmware',
                                    'targets'              => $vmware_targets,
                                    'action'               => 'delete',
                                    'target_name_property' => 'hostname',
                                    'vsphere_host'         => $vsphere_host,
                                    'vsphere_username'     => $vsphere_username,
                                    'vsphere_password'     => $vsphere_password,
                                    'vsphere_datacenter'   => $vsphere_datacenter,
                                    'vsphere_insecure'     => $vsphere_insecure,
                                    'snapshot_name'        => 'pe_patch_snapshot',
                                    'noop'                 => $noop,
                                    '_catch_errors'        => true)

        # if snapshot plan run in noop, return vmware_targets as "done"
        if $noop {
          $snapshot_removed = $vmware_targets
          $snapshot_failed = []
        } else {
          if $remove_snapshot.empty {
            $snapshot_removed = $vmware_targets
            $snapshot_failed = []
          } else {
            $snapshot_removed = []
            $snapshot_failed = $vmware_targets
          }
        }
      }
    }
  }

  # Output the results
  return({
    'patch_group'        => $patch_group,
    'all_nodes_in_group' => $full_list,
    'eligible_nodes'     => $targets,
    'vmware_nodes'       => $vmware_targets,
    'snapshot_removed'   => $snapshot_removed,
    'snapshot_failed'    => $snapshot_failed,
    'counts'                     => {
      'all_nodes_in_group_count' => $full_list.count,
      'eligible_nodes_count'     => $targets.count,
      'vmware_nodes_count'       => $vmware_targets.count,
      'snapshot_removed_count'   => $snapshot_removed.count,
      'snapshot_failed_count'    => $snapshot_failed.count,
    }
  })
}
