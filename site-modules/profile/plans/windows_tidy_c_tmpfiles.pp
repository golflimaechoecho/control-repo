# plan to delete *.tmp files under C:\
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

  # https://puppet.com/docs/puppet/6.18/types/tidy.html
  # to use matches, recurse must be non-zero/non-false.
  # specify recurse = 1 to not descend into subdirectories
  if ! $recurse {
    $recurse_real = 1
  } else {
    $recurse_real = $recurse
  }

  $results = apply($windows_targets, '_catch_errors' => true, '_noop' => $noop) {
    tidy { 'c_tmpfiles':
      path    => $tidypath,
      matches => [ '*.tmp' ],
      recurse => $recurse_real,
    }
  }

  return($results)
}
