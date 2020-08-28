# cleanup terrible attempt at datacentre fact
#
class profile::datacentre {
  # os specific factpath, separator, newline
  case $facts['os']['name'] {
    'windows': {
      # OK to use forward slash for file path attribute
      # https://puppet.com/docs/puppet/6.17/lang_windows_file_paths.html
      $factdir = 'C:/ProgramData/PuppetLabs/facter/facts.d'
      $newline_char = "\r\n"
    }
    default: {
      $factdir = '/etc/puppetlabs/facter/facts.d'
      $newline_char = "\n"
    }
  }

  $factpath = "${factdir}/datacentre.yaml"

  file { $factpath:
    ensure  => absent,
  }
  if $facts['os']['family'] == 'RedHat' {
    $dirname_one_up = dirname($factdir)
    # parent dir(s) absent on linux; they were automagically there on windows
    file { [ $dirname_one_up, $factdir ]:
      ensure => absent,
    }
  }
}
