# class to install rbvmomi gem and dependencies
# intended to be applied on PE primary server
class profile::rbvmomi {
  $gem_pkgs = [ 'builder', 'json', 'nokogiri', 'mini_portile', 'rbvmomi' ]

  # package dependencies for nokogiri java native extension
  $dep_rpms = [ 'make', 'gcc', 'rpm-build', 'ruby-devel', 'zlib-devel' ]

  package { $dep_rpms:
    ensure => installed,
  }

  package { $gem_pkgs:
    ensure   => installed,
    provider => puppet_gem,
  }
}
