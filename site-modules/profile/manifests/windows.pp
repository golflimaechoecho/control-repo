# profile for windows
class profile::windows {
  user { 'gluser':
    ensure     => present,
    forcelocal => true,
  }
  group { 'glgroup':
    ensure  => present,
    members => ['gluser'],
  }
  dsc_userrightsassignment { 'gluser_rights':
    dsc_ensure   => present,
    dsc_identity => 'gluser',
    dsc_policy   => 'Log_on_as_a_service',
  }
}
