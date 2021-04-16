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
  # patching::snapshot_vmware appears to take vsphere details from first target (ie: assumes all on same)
  # to be able to lookup indiv details, need to iterate on loop ie: take snapshots serially not in parallel
  # Work out vm_names to snapshot (hardcoded to hostname here)
  #$vm_names = patching::target_names($targets, 'hostname')
  $_targets = $targets.get_targets()
  $snap_results = apply($_targets) {
    $_targets.each | $target | {
      #$snap_result = apply($target) {
      $vsphere_servers = lookup('profile::pe_patch::vsphere_servers')
      $vsphere_host = lookup('profile::pe_patch::vsphere_host')
      $vsphere_username = $vsphere_servers[$vsphere_host]['vsphere_username']

      if $vsphere_host in $vsphere_servers {
        notify { "${target}.host,  host: ${vsphere_host}, other: ${vsphere_username}, ${vsphere_servers[$vsphere_host]['vsphere_password']}, ${vsphere_servers[$vsphere_host]['vsphere_datacenter']}, ${vsphere_servers[$vsphere_host]['vsphere_insecure']}": }
      }
    }
    #$report = $snap_result.results[0].report['resource_statuses']
    #out::message("report is $report")
  }
  $snap_results.each | $result | {
    $report = $result.report['resource_statuses']
    out::message("report is $report")
  }
}
