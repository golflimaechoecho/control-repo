plan profile::test (
  TargetSpec $targets,
) {
  run_task(facter_tasks, $targets, '_catch_errors' => true)
  run_task(facter_tasks, $targets)
  run_plan(facts, targets => $targets)
}
