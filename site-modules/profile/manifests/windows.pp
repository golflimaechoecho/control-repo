# profile for windows
class profile::windows {
  $user  = 'gluser'
  $group = 'glgroup'

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
  file { "C:\\ProgramData\\${user}":
    ensure => directory,
    owner  => $user,
    group  => $group,
  }
}
