# gitlab profile
class profile::gitlab {
  include gitlab

  file { [ '/etc/puppetlabs/facter', '/etc/puppetlabs/facter/facts.d' ]:
    ensure => directory,
  }

  file { '/etc/puppetlabs/facter/facts.d/userlist.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/userlist.sh',
  }
}
