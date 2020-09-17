plan profile::test (
  TargetSpec $targets,
  Optional[String[1]] $parameter,
) {
  #run_task(facter_task, $targets, '_catch_errors' => true)
  get_targets($targets).each | $target | {
    $vsphere_host = lookup('profile::test::vsphere_host')
    run_command("echo parameter is ${parameter}, vsphere host is ${vsphere_host}", $target)
  }
  #run_plan(facts, targets => $targets)
}
