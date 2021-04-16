# @summary test plan
#
# bolt supports --hiera-config and using plan_hierarchy, this doesn't appear available in PE yet
#
plan profile::test (
  TargetSpec $targets,
) {
  #run_task(facter_task, $targets, '_catch_errors' => true)
  #run_plan(facts, targets => $targets)
  apply_prep($targets)
  #apply_prep($node_healthy)
  $to_snapshot = $targets.get_targets()
        $snapshot_results = $to_snapshot.reduce([]) | $memo, $snapshot_target | {
          $snapshot_result = apply($snapshot_target, '_catch_errors' => true) {
            # vcenter has hosts defined with hostname (shortname); match this to take snapshot
            $snapshot_hostname = $snapshot_target.host

            # vsphere_servers could be moved to plan_hierarchy to perform lookup
            # outside apply block (rather than repeating for each target)
            # requires PE 2019.8.5+; this would also mean need to duplicate/keep
            # in sync if details needed in standard hiera
            # https://puppet.com/docs/bolt/latest/hiera.html#outside-apply-blocks
            $vsphere_servers = lookup('profile::pe_patch::vsphere_servers')

            # vsphere_host needs to stay in loop as must be looked up per-target
            $vsphere_host = lookup('profile::pe_patch::vsphere_host')

            if $vsphere_host in $vsphere_servers {
              notify { "notify for $snapshot_hostname": }
              notify { "snapshot for $snapshot_hostname":
                message => "patching::snapshot_vmware($snapshot_hostname, 'pe_patch_snapshot', $vsphere_host, $vsphere_servers[$vsphere_host]['vsphere_username'], $vsphere_servers[$vsphere_host]['vsphere_password'], $vsphere_servers[$vsphere_host]['vsphere_datacenter'], $vsphere_servers[$vsphere_host]['vsphere_insecure'], '', false, true, 'create')",
              }
              # call function directly with current defaults from
              # https://github.com/EncoreTechnologies/puppet-patching/blob/master/plans/snapshot_vmware.pp
              patching::snapshot_vmware($snapshot_hostname,
                                        'pe_patch_snapshot',
                                        $vsphere_host,
                                        $vsphere_servers[$vsphere_host]['vsphere_username'],
                                        $vsphere_servers[$vsphere_host]['vsphere_password'],
                                        $vsphere_servers[$vsphere_host]['vsphere_datacenter'],
                                        $vsphere_servers[$vsphere_host]['vsphere_insecure'],
                                        '',
                                        false,
                                        true,
                                        'create')
            } else {
              fail("Unable to find specified vsphere_host ${vsphere_host} for ${snapshot_target}")
            }
          }
          $memo + $snapshot_result
        }

        # hopefully this is a resultset??
        #$mytype = type($snapshot_results)
        #out::message("Snapshot result is: ${mytype}")
        $snapshot_results.each | $snap_result | {
          #$report = $snap_result.results[0].report['resource_statuses']
          $mytype = type($snap_result.results)
          out::message("result is: ${mytype}")
          $report = $snap_result.results[0].report
          out::message("report is $report")
        }

  # patching::snapshot_vmware appears to take vsphere details from first target (ie: assumes all on same)
  # to be able to lookup indiv details, need to iterate on loop ie: take snapshots serially not in parallel
  # Work out vm_names to snapshot (hardcoded to hostname here)
    ##  $_targets = $targets.get_targets()
    ##  $_targets.each | $target | {
    ##    $snap_result = apply($target) {
    ##      $snapname = regsubst($target.uri, '^([^.]+).*','\1')
    ##      notify { $snapname: }
    ##      $vsphere_servers = lookup('profile::pe_patch::vsphere_servers')
    ##      $vsphere_host = lookup('profile::pe_patch::vsphere_host')
    ##      $vsphere_username = $vsphere_servers[$vsphere_host]['vsphere_username']
    ##
    ##      if $vsphere_host in $vsphere_servers {
    ##        notify { "${snapname}, host: ${vsphere_host}, other: ${vsphere_username}, ${vsphere_servers[$vsphere_host]['vsphere_password']}, ${vsphere_servers[$vsphere_host]['vsphere_datacenter']}, ${vsphere_servers[$vsphere_host]['vsphere_insecure']}": }
    ##      }
    ##    }
    ##    $report = $snap_result.results[0].report['resource_statuses']
    ##    out::message("report is $report")
    ##  }
    ##  #$snap_results.each | $result | {
    ##  #  $report = $result.report['resource_statuses']
    ##  #  out::message("report is $report")
    ##  #}
}
