plan profile::test (
  TargetSpec $targets,
  Optional[String[1]] $parameter = lookup('profile::test::parameter', { 'default_value' => undef }),
) {
  #run_task(facter_task, $targets, '_catch_errors' => true)
  apply($targets) {
    $vsphere_host = lookup('profile::test::vsphere_host')
    notify { "echo parameter is ${parameter}, vsphere host is ${vsphere_host}": }
  }
  #run_plan(facts, targets => $targets)
}
