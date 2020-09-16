# @summary plan to delete *.tmp files under C:\
#
# originally planned to use tidy resource, however this fails with permission
# denied errors for C:\Documents and Settings\...
#
# @param targets Targets to tidy
# @param recurse Whether to recursively descend to tidy. Defaults to false.
# @param noop Whether to run in noop. Defaults to false (ie: will remove files)
plan profile::windows_tidy_c_tmpfiles (
  TargetSpec $targets,
  Stdlib::Absolutepath $tidypath = 'C:\\',
  Boolean $recurse = false,
  Boolean $noop = false,
) {
  run_plan(facts, targets => $targets, '_catch_errors' => true)

  # Filter windows targets only
  $windows_targets = get_targets($targets).filter | $target | {
    $target.facts['os']['name'] == 'windows'
  }

  # extra backslash escaping
  $command = "del ${tidypath}\\*.tmp /s /q"
  out::message("Run tmpfile cleanup: ${command}")

  $results = run_command($command, $windows_targets, '_catch_errors' => true, '_noop' => $noop)

  return($results)
}
