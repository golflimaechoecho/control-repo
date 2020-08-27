# populate datacentre fact using datacentre top-scope variable $dc set in site.pp
# Note: fact will not be available in the first run as it needs to be set using
# the variable; however it can be used from second run onwards for classification
#
class profile::datacentre {
  # os specific factpath, separator, newline
  case $facts['os']['name'] {
    'windows': {
      # OK to use forward slash for file path attribute
      # https://puppet.com/docs/puppet/6.17/lang_windows_file_paths.html
      $factdir = 'C:/ProgramData/PuppetLabs/facter/facts.d'
      $newline_char = "\r\n"
      $ownership_attrs = {}
    }
    default: {
      $factdir = '/etc/puppetlabs/facter/facts.d'
      $newline_char = "\n"
      $ownership_attrs = {
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      }
    }
  }

  $dirname_one_up = dirname($factdir)

  $factpath = "${factdir}/datacentre.yaml"

  # ensure parent dir(s) exist
  file { [ $dirname_one_up, $factdir ]:
    ensure => directory,
    *      => $ownership_attrs,
  }

  file { $factpath:
    ensure  => file,
    content => "---${newline_char}datacentre: ${::dc}${newline_char}",
    *       => $ownership_attrs,
  }
}
