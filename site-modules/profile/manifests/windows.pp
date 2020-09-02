# profile for windows
class profile::windows {
  include profile::wsus_client

  $user  = 'gluser'
  $group = 'glgroup'
  $userdir = "C:\\ProgramData\\${user}"

  user { $user:
    ensure     => present,
    forcelocal => true,
  }
  group { $group:
    ensure  => present,
    members => [$user],
  }
  dsc_userrightsassignment { "${user}_Log_on_as_a_service":
    dsc_ensure   => present,
    dsc_identity => $user,
    dsc_policy   => 'Log_on_as_a_service',
  }
  file { $userdir:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }
  acl { $userdir:
    permissions  => [
      { identity => $user, rights => ['full'] },
      { identity => $group, rights => ['read'] },
    ],
  }
  acl { "remove_${user}":
    target       => $userdir,
    purge        => 'listed_permissions',
    permissions  => [
      { identity => $group, rights => ['full'] },
    ],
  }
}
