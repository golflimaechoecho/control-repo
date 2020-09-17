# @summary test plan
#
# bolt supports --hiera-config and using plan_hierarchy, this doesn't appear available in PE yet
#
plan profile::test (
  TargetSpec $targets,
  Optional[String[1]] $parameter = undef,
) {
  #run_task(facter_task, $targets, '_catch_errors' => true)
  #run_plan(facts, targets => $targets)
  $results = apply($targets) {
    $_parameter = lookup('profile::test::parameter', { 'default_value' => undef })
    $vsphere_host = lookup('profile::test::vsphere_host')
    notify { "echo parameter is ${parameter}, _parameter is ${_parameter}, vsphere host is ${vsphere_host}": }
  }
  $results.each | $result | {
    $report = $result.report
    out::message("report is $report")
  }
  return()
}
