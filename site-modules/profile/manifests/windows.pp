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

  # registry keys
  # below settings are when DISABLED (0), change data to 1 for ENABLED
  # registry_settings:
  #   'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled':
  #     key: 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
  #     value: 'IsInstalled'
  #     type: 'dword'
  #     data: 0
  #   'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled':
  #     key: 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
  #     value: 'IsInstalled'
  #     type: 'dword'
  #     data: 0
  #   'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled':
  #     key: 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
  #     value: 'IsInstalled'
  #     type: 'dword'
  #     data: 0
  #   'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\IEHarden':
  #     key: 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
  #     value: 'IEHarden'
  #     type: 'dword'
  #     data: 0
  #   'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\IEHarden':
  #     key: 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
  #     value: 'IEHarden'
  #     type: 'dword'
  #     data: 0

  $ieesc_registry_settings = {
    'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled' => {
      key   => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}',
      value => 'IsInstalled',
      type  => 'dword',
      data  => 1
    },
    'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled' => {
      key   => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
      value => 'IsInstalled',
      type  => 'dword',
      data  => 1
    },
    'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled' => {
      key   =>  'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
      value => 'IsInstalled',
      type  => 'dword',
      data  => 1
    },
    'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\IEHarden' => {
      key   => 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap',
      value => 'IEHarden',
      type  => 'dword',
      data  => 1
    },
    'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\IEHarden' => {
      key   => 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap',
      value => 'IEHarden',
      type  => 'dword',
      data  => 1
    }
  }

  $ieesc_registry_settings.each | String $keyname, Hash $keyattributes | {
    registry::value { $keyname:
      notify => Exec[$rundll_execs],
      *      => $keyattributes,
    }
  }

  $rundll_list = [ 'IEHardenUser', 'IEHardenAdmin', 'IEHardenMachineNow' ]

  $rundll_execs = $rundll_list.map | String $toharden | {
    "Rundll iesetup.dll,${toharden}"
  }

  # exec rundll only if ieesc registry keys changed
  exec { $rundll_execs:
    refreshonly => true,
  }
}
