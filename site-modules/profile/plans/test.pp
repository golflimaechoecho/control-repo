# @summary test plan
#
# bolt supports --hiera-config and using plan_hierarchy, this doesn't appear available in PE yet
#
plan profile::test (
  TargetSpec $targets,
  #Optional[String[1]] $parameter = undef,
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
    notify { "servers ${vsphere_servers}, host ${vsphere_host}": }
    #if $vsphere_host in $vsphere_servers {
    #  $targets.each | $node | {
    #    notify { [ $node,
    #               'pe_patch_snapshot',
    #               $vsphere_host,
    #               $vsphere_servers[$vsphere_host][$vsphere_username],
    #               $vsphere_servers[$vsphere_host][$vsphere_password],
    #               $vsphere_servers[$vsphere_host][$vsphere_datacenter],
    #               $vsphere_servers[$vsphere_host][$vsphere_insecure],
    #               '',
    #               false,
    #               true,
    #               'create' ]:
    #    }
    #  }
    #}
  }
  $results.each | $result | {
    $report = $result.report['resource_statuses']
    out::message("report is $report")
  }
}
