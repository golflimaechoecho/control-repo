# @summary profile to manage puppet agent
class profile::puppet_agent {
  #ensure puppet agent service is running
  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
