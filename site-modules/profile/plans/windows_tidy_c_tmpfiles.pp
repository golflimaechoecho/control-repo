# plan to delete *.tmp files under C:\
plan profile::windows_tidy_c_tmpfiles (
  TargetSpec $targets,
){
  $results = apply($targets, '_catch_errors' => true, '_noop' => true) {
    # https://puppet.com/docs/puppet/6.18/types/tidy.html
    tidy { 'c_tmpfiles':
      path    => 'C:\\',
      age     => 0,
      matches => [ '*.tmp' ],
      recurse => false,
    }
  }
}
