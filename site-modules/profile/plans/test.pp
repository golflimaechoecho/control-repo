plan profile::test (
  TargetSpec $targets,
) {
  #run_task(facter_task, $targets, '_catch_errors' => true)
  get_targets($targets).each | $target | {
    $target_old_uri = $target.uri
    run_command("echo 'uri for ${target}: ${target_old_uri}'", $target)
    $uri_upcase = upcase($target.uri)
    $target.set_var('uri', $uri_upcase)
    $target_new_uri = $target.uri
    run_command("echo 'updated vars for ${target}: ${target_new_uri}'", $target)
  }
  #run_plan(facts, targets => $targets)
}
