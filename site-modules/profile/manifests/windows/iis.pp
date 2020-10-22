# manage iis
#
# PS homework states to install with dsc_lite, create with website with iis
#
# Cheated slightly as iis can do both and it seems daft to use two modules instead of one
#
# for the sake of PS homework steps, the commented out Dsc['iis'] resource
# would/should be the equivalent of iis_feature resource
#
# mod 'puppetlabs-dsc_lite', '3.0.1'
# mod 'puppetlabs-iis', '7.1.0'
#
class profile::windows::iis {
  #dsc { 'iis':
  #  resource_name => 'WindowsFeature',
  #  module        => 'PSDesiredStateConfiguration',
  #  properties    => {
  #    ensure => 'present',
  #    name   => 'Web-Server',
  #  }
  #}

  $minimal_path = 'c:\\inetpub\\minimal'
  $iis_features = ['Web-WebServer','Web-Scripting-Tools']

  iis_feature { $iis_features:
    ensure => 'present',
  }

  # Delete the default website to prevent a port binding conflict.
  iis_site {'Default Web Site':
    ensure  => absent,
    require => Iis_feature['Web-WebServer'],
  }

  iis_application_pool { 'minimal_site_app_pool':
    ensure                  => 'present',
    state                   => 'started',
    managed_pipeline_mode   => 'Integrated',
    managed_runtime_version => 'v4.0',
  }

  iis_site { 'minimal':
    ensure          => 'started',
    physicalpath    => $minimal_path,
    applicationpool => 'minimal_site_app_pool',
    require         => [
      File['minimal'],
      Iis_site['Default Web Site'],
      Iis_application_pool['minimal_site_app_pool'],
    ],
  }

  file { 'minimal':
    ensure => 'directory',
    path   => $minimal_path,
  }

  acl { $minimal_path:
    permissions => [
      {'identity' => 'IIS_IUSRS', 'rights' => ['read', 'execute']},
    ],
  }
}
