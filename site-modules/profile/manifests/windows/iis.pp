# manage iis
#
# install with dsc_lite, create with website with iis
# (presumably IIS could do both of these, using two modules instead of one as
# instructed by PS homework steps)
#
# mod 'puppetlabs-dsc_lite', '3.0.1'
# mod 'puppetlabs-iis', '7.1.0'
class profile::windows::iis {
  #dsc { 'iis':
  #  resource_name => 'WindowsFeature',
  #  module        => 'PSDesiredStateConfiguration',
  #  properties    => {
  #    ensure => 'present',
  #    name   => 'Web-Server',
  #  }
  #}

  $iis_features = ['Web-WebServer','Web-Scripting-Tools']

  iis_feature { $iis_features:
    ensure => 'present',
  }

  # Delete the default website to prevent a port binding conflict.
  iis_site {'Default Web Site':
    ensure  => absent,
    require => Iis_feature['Web-WebServer'],
  }

  iis_site { 'minimal':
    ensure          => 'started',
    physicalpath    => 'c:\\inetpub\\minimal',
    applicationpool => 'DefaultAppPool',
    require         => [
      File['minimal'],
      Iis_site['Default Web Site']
    ],
  }

  file { 'minimal':
    ensure => 'directory',
    path   => 'c:\\inetpub\\minimal',
  }
}
