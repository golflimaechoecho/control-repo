# profile for windows
class profile::windows {
  include archive
  include chocolatey
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

  # IEESC settings have notify for Exec['Rundll32 iesetup.dll,IEHardenAdmin']
  $registry_settings = {
    'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled' => {
      key    => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}',
      value  => 'IsInstalled',
      type   => 'dword',
      data   => 1,
      tag    => ['ieesc'],
      notify => Exec['Rundll32 iesetup.dll,IEHardenAdmin'],
    },
    'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled' => {
      key    => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
      value  => 'IsInstalled',
      type   => 'dword',
      data   => 1,
      tag    => ['ieesc'],
      notify => Exec['Rundll32 iesetup.dll,IEHardenAdmin'],
    },
    'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}\IsInstalled' => {
      key    =>  'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
      value  => 'IsInstalled',
      type   => 'dword',
      data   => 1,
      tag    => ['ieesc'],
      notify => Exec['Rundll32 iesetup.dll,IEHardenAdmin'],
    },
    'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\IEHarden' => {
      key   => 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap',
      value => 'IEHarden',
      type  => 'dword',
      data  => 1,
      tag    => ['ieesc'],
      notify => Exec['Rundll32 iesetup.dll,IEHardenAdmin'],
    },
    'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\IEHarden' => {
      key    => 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap',
      value  => 'IEHarden',
      type   => 'dword',
      data   => 1,
      tag    => ['ieesc'],
      notify => Exec['Rundll32 iesetup.dll,IEHardenAdmin'],
    },
    'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability\ShutdownReasonUI' => {
      key   => 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability',
      value => 'ShutdownReasonUI',
      type  => 'dword',
      data  => 1, # to disable, ensure => absent; also check HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability\
      tag   => ['shutdown_event_tracker'],
    },
    'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability\ShutdownReasonOn' => {
      key   => 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability',
      value => 'ShutdownReasonOn',
      type  => 'dword',
      data  => 1, # to disable, set to 1
      tag   => ['shutdown_event_tracker'],
    },
  }

  $registry_settings.each | String $keyname, Hash $keyattributes | {
    registry::value { $keyname:
      * => $keyattributes,
    }
  }

  $rundll_list = [ 'IEHardenUser', 'IEHardenAdmin', 'IEHardenMachineNow' ]

  $rundll_execs = $rundll_list.map | String $toharden | {
    "Rundll32 iesetup.dll,${toharden}"
  }

  # exec rundll only if ieesc registry keys changed
  exec { $rundll_execs:
    path        => 'C:\\Windows\\system32',
    refreshonly => true,
  }

  # reboot after 7zip installed
  # Package['7zip'] is from archive module
  reboot { 'post_7zip':
    subscribe => Package['7zip'],
  }
}
