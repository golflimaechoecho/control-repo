# plan to delete *.tmp files under C:\
# @param targets Targets to tidy
# @param recurse Whether to recursively descend to tidy. Defaults to false.
# @param noop Whether to run in noop. Defaults to false (ie: will remove files)
plan profile::windows_tidy_c_tmpfiles (
  TargetSpec $targets,
  Boolean recurse = false,
  Boolean noop = false,
){
  $results = apply($targets, '_catch_errors' => true, '_noop' => true) {
    # https://puppet.com/docs/puppet/6.18/types/tidy.html
    tidy { 'c_tmpfiles':
      path    => 'C:\\',
      age     => 0,
      matches => [ '*.tmp' ],
      recurse => $recurse,
      noop    => $noop,
    }
  }
}
