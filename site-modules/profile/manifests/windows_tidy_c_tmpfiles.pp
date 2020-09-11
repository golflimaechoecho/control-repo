# profile to tidy c:\*.tmp files
# NOTE: not applied directly, used by plan profile::windows_tidy_c_tmpfiles
class profile::windows_tidy_c_tmpfiles (
  Boolean $recurse = false,
) {
  if ! $recurse {
    $recurse_real = 1
  } else {
    $recurse_real = $recurse
  }
  tidy { 'c_tmpfiles':
    path    => 'C:\\',
    matches => [ '*.tmp' ],
    recurse => $recurse_real,
  }
}
