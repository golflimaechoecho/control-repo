# based on http://bit.ly/PuppetPatchingPlans
# https://gist.github.com/albatrossflavour/793417acf9d308b62a7d08e68b5a4c2e
plan profile::auto_patch (
  String $patch_group,
  Boolean $security_only = false,
  Enum['always', 'never', 'patched', 'smart'] $reboot = 'patched',
  Boolean $noop = false,
  Boolean $perform_backup = true,
){
  # Query PuppetDB to find nodes that have the patch group,
  # are not blocked and have patches to apply
  $all_nodes = puppetdb_query("inventory[certname] { facts.pe_patch.patch_group = '${patch_group}'}")
  $filtered_nodes = puppetdb_query("inventory[certname] { facts.pe_patch.patch_group = '${patch_group}' and facts.pe_patch.blocked = false and facts.pe_patch.package_update_count > 0}")

  # Transform the query output into Targetspec
  $full_list = $all_nodes.map | $r | { $r['certname'] }
  $certnames = $filtered_nodes.map | $r | { $r['certname'] }
  $targets = get_targets($certnames)

  # Start the work
  if $targets.empty {
    # Set the return variables to empty as there is nothing to patch
    $puppet_not_healthy = []
    $node_not_healthy = []
    $not_patched = []
    $check_failed = []
    $check_passed = []
    $post_update_failed = []
  } else {
    # Check the health of the puppet agent on all nodes
    $agent_health = run_task('puppet_health_check::agent_health', $targets, '_catch_errors' => true)

    # Pull out list of those that are ok/in error
    $puppet_healthy = $agent_health.ok_set.names
    $puppet_not_healthy = $agent_health.error_set.names

    # Proceed there are healthy agents
    if $puppet_healthy.empty {
      $node_not_healthy = []
      $not_patched = []
      $check_failed = []
      $check_passed = []
      $post_update_failed = []
    } else {
      # Do pre-patching health checks
      $health_check = run_task('enterprise_tasks::run_puppet', $puppet_healthy, '_catch_errors' => true)

      # Pull out list of those that are ok/in error
      $node_healthy = $health_check.ok_set.names
      $node_not_healthy = $health_check.error_set.names

      # Proceed there are health nodes
      if $node_healthy.empty {
        $not_patched = []
        $check_failed = []
        $check_passed = []
        $post_update_failed = []
      } else {
        # Use inbuilt pe_patch::pre_patching_scriptpath rather than separate patching::pre_update task

        if $perform_backup {
          out::message('Perform snapshot here')

          # Take snapshots prior to patching
          # patching::snapshot_vmware takes vsphere details from first target
          # (assumes have same details); to be able to lookup individual details
          # ie: snapshots taken serially not in parallel

          # get facts for snapshot targets
          run_plan(puppetdb_fact, targets => $node_healthy)

          # assumes vsphere_servers lives in plan_hierarchy to perform lookup
          # outside apply block (static rather than per target)
          # requires PE 2019.8.5+; this would also mean need to duplicate/keep
          # in sync if details needed in standard hiera
          # https://puppet.com/docs/bolt/latest/hiera.html#outside-apply-blocks
          $vsphere_servers = lookup('profile::vsphere_details::vsphere_servers')

          # At present this assumes all targets in the given patch_group have identical vcenter details
          # (takes details based on first target in $node_healthy)
          $vsphere_datacenter = get_targets($node_healthy)[0].facts['vsphere_details']['vsphere_datacenter']
          $vsphere_host = get_targets($node_healthy)[0].facts['vsphere_details']['vsphere_host']
          if $vsphere_host in $vsphere_servers {
            $vsphere_username = $vsphere_servers[$vsphere_host]['vsphere_username']
            $vsphere_password = $vsphere_servers[$vsphere_host]['vsphere_password']
            $vsphere_insecure = $vsphere_servers[$vsphere_host]['vsphere_insecure']
          } else {
            fail_plan("Unable to find details for vsphere_host ${vsphere_host}")
          }
          $to_snapshot = run_plan('patching::snapshot_vmware',
                                  'targets'              => $node_healthy,
                                  'action'               => 'create',
                                  'target_name_property' => 'hostname',
                                  'vsphere_host'         => $vsphere_host,
                                  'vsphere_username'     => $vsphere_username,
                                  'vsphere_password'     => $vsphere_password,
                                  'vsphere_datacenter'   => $vsphere_datacenter,
                                  'vsphere_insecure'     => $vsphere_insecure,
                                  'snapshot_name'        => 'pe_patch_snapshot',
                                  'noop'                 => $noop,
                                  '_catch_errors'        => true)

          $to_snap_type = type($to_snapshot)
          out::message("to_snapshot is ${to_snap_type}")

          # if plan run in noop, probably not getting correct result, fudge to use node_healthy for now
          if $noop {
            $snapshot_done = $node_healthy
            $snapshot_failed = []
          } else {
            $snapshot_done = $to_snapshot.ok_set.names
            $snapshot_failed = $to_snapshot.error_set.names
          }
        } else {
          out::message("\$perform_backup set to false, skipping snapshot")
          # use node_healthy as list to continue
          $snapshot_done = $node_healthy
          $snapshot_failed = []
        }

        out::message('PLACEHOLDER: disable monitoring here')
        ### Conceptually this would look like:
        #$to_pre_monitor = run_task('monitoring::disable', $snapshot_done, '_catch_errors' =>  true)
        #$pre_monitor_done = $to_pre_monitor.ok_set.names
        #$pre_monitor_failed = $to_pre_monitor.error_set.names

        # For now, setup lists with naming only
        $pre_monitor_done = $snapshot_done
        $pre_monitor_failed = []

        if $noop {
          out::message("INFO: (noop) run_task pe_patch::patch_server")
          $patched = []
          $not_patched = []
        } else {
          # Actually carry out the patching on all healthy nodes
          $to_patch = run_task('pe_patch::patch_server',
                                $pre_monitor_done,
                                reboot          => $reboot,
                                security_only   => $security_only,
                                '_catch_errors' => true
                      )
          # Pull out list of those that are ok/in error
          $patched = $to_patch.ok_set.names
          $not_patched = $to_patch.error_set.names
        }

        # Wait until the nodes are back up
        # NB: should this be checking patched (or snapshot) list rather than all node_healthy?
        $to_post_check = wait_until_available($node_healthy, wait_time => 300)

        # Pull out list of those that are ok/in error
        $rebooted = $to_post_check.ok_set.names
        $not_rebooted = $to_post_check.error_set.names

        # Re-enable monitoring before post-checks?
        out::message('PLACEHOLDER: reenable monitoring here')
        ### Conceptually this would look like:
        #$to_post_monitor = run_task('monitoring::enable', $snapshot_done, '_catch_errors' =>  true)
        #$post_monitor_done = $to_post_monitor.ok_set.names
        #$post_monitor_failed = $to_post_monitor.error_set.names
        # For purposes of placeholder, assume post_update can be configured to
        # check monitoring re-enabled rather than setting up additional dummy lists

        # Do post-patching health checks
        # this caters for post-reboot tasks
        $to_post_update = run_task('patching::post_update',
                              $rebooted,
                              '_catch_errors' => true
                          )

        $post_update_done = $to_post_update.ok_set.names
        $post_update_failed = $to_post_update.error_set.names
        $post_check = run_task('enterprise_tasks::run_puppet', $post_update_done, '_catch_errors' => true)
        $check_passed = $post_check.ok_set.names
        $check_failed = $post_check.error_set.names
      }
    }
  }

  # Output the results
  return({
    'patch_group'                => $patch_group,
    'all_nodes_in_group'         => $full_list,
    'patchable_nodes'            => $targets,
    'puppet_health_check_failed' => $puppet_not_healthy,
    'node_health_check_failed'   => $node_not_healthy,
    'patching_failed'            => $not_patched,
    'post_check_failed'          => $check_failed,
    'nodes_patched'              => $check_passed,
    'post_update_failed'         => $post_update_failed,
    'counts'                     => {
      'all_nodes_in_group_count'   => $full_list.count,
      'patchable_nodes_count'      => $targets.count,
      'puppet_health_check_failed' => $puppet_not_healthy.count,
      'node_health_check_failed'   => $node_not_healthy.count,
      'patching_failed'            => $not_patched.count,
      'post_check_failed'          => $check_failed.count,
      'nodes_patched'              => $check_passed.count,
      'post_update_failed'         => $post_update_failed.count,
    }
  })
}
