# populate datacentre fact using datacentre top-scope variable set in site.pp
# Note: fact will not be available in the first run as it needs to be set using
# the variable; however it can be used from second run onwards for classification
#
class profile::datacentre {
  # os specific factpath, separator, newline
  case $facts['os']['name'] {
    'windows': {
      $factdir = 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\'
      $separator_char = '\\'
      $newline_char = "\r\n"
      $ownership_attrs = {}
    }
    default: {
      $factdir = '/etc/puppetlabs/facter/facts.d/'
      $separator_char = '/'
      $newline_char = "\n"
      $ownership_attrs = {
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      }
    }
  }

  $dirname_one_up = dirname($factdir)
  $dirname_two_up = dirname($dirname_one_up)

  $factpath = "${factpath}${separator_char}datacentre.yaml"


  # ensure parent dir(s) exist
  file { [ $dirname_two_up, $dirname_one_up ]:
    ensure => directory,
    *      => $ownership_attrs,
  }

  file { $factpath:
    ensure  => file,
    content => "---${newline_char}datacentre: ${datacentre}${newline_char}",
    *       => $ownership_attrs,
  }
}
