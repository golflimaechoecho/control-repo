# class to install rbvmomi gem and dependencies
# intended to be applied on PE primary server
# note: pe-orchestration-services must be restarted after installing gems
class profile::rbvmomi {
  $dep_gems = [ 'builder', 'json', 'mini_portile2' ]

  # package dependencies for nokogiri native extension
  $dep_rpms = [ 'make', 'gcc', 'rpm-build', 'ruby-devel', 'zlib-devel' ]

  package { $dep_rpms:
    ensure => installed,
  }

  package {
    default:
      ensure   => installed,
      provider => puppet_gem,
    ;
    $dep_gems:
    ;
    # special case for nokogiri java extension
    # assumes file has been downloaded separately eg: gem fetch nokogiri --platform=java
    'nokogiri':
      source => '/root/nokogiri-1.11.3-java.gem',
    ;
    'rbvmomi':
      require => Package['nokogiri'],
      notify  => Exec['restart pe-orchestration-services'],
    ;
  }

  exec { 'restart pe-orchestration-services':
    command     => '/bin/systemctl restart pe-orchestration-services',
    refreshonly => true,
  }
}
