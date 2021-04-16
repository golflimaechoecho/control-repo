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
  $parameter = lookup('profile::test::parameter', { 'default_value' => undef })
  $results = apply($targets) {
    #$_parameter = lookup('profile::test::parameter', { 'default_value' => undef })
    #$vsphere_host = lookup('profile::test::vsphere_host')
    #notify { "echo parameter is ${parameter}, _parameter is ${_parameter}, vsphere host is ${vsphere_host}": }
    $vsphere_servers = lookup('profile::pe_patch::vsphere_servers')
    $vsphere_host = lookup('profile::pe_patch::vsphere_host')
    #{ "servers ${vsphere_servers}, host ${vsphere_host}": }

    $vm_names = patching::target_names($targets, 'hostname')
    if $vsphere_host in $vsphere_servers {
      notify { "vm_names: ${vm_names},  host: ${vsphere_host}, other: ${vsphere_servers[$vsphere_host][$vsphere_username]}, ${vsphere_servers[$vsphere_host][$vsphere_password]}, ${vsphere_servers[$vsphere_host][$vsphere_datacenter]}, ${vsphere_servers[$vsphere_host][$vsphere_insecure]}" }
    }
  }
  $results.each | $result | {
    $report = $result.report['resource_statuses']
    out::message("report is $report")
  }
}
