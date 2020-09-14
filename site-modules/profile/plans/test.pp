plan profile::test (
  TargetSpec $targets,
) {
  run_task(facter_task, $targets, '_catch_errors' => true)
  get_targets($targets).each | $target | {
    $targetvars = $target.vars
    run_command("echo vars for ${target}: ${targetvars}", $target)
    $uri_upcase = upcase($target.uri)
    $target.set_var('uri', $uri_upcase)
    run_command("echo 'updated vars for ${target}: ${targetvars}'", $target)
  }
  run_plan(facts, targets => $targets)
}
