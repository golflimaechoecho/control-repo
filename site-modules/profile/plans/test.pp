plan profile::test (
  TargetSpec $targets,
) {
  run_task(facter_task, $targets, '_catch_errors' => true)
  run_task(facter_task, $targets)
  run_plan(facts, targets => $targets)
}
