require 'json'

# License Server Facter
Facter.add('citrix_license_server') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    case Facter.value(:kernelmajversion)
    when '6.1'
      value = nil
      begin
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\Wow6432node\Citrix\Licensing') do |regkey|
          value = regkey['MFCM_LSHostName']
        end
      rescue
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Policies\Citrix\IMA\Licensing') do |regkey|
          value = regkey['LicenseServerHostName']
        end
      end
      value
    when '6.3', '10.0'
      value = nil
      begin
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['LicenseServerName']
        end
      rescue
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['LicenseServerName']
        end
      end
      value
    end
  end
end

# Delivery Controller Facter
Facter.add('citrix_delivery_controller') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    case Facter.value(:kernelmajversion)
    when '6.1'
      domain = Facter.value(:networking)['domain']
      value = case domain
              when 'globaltest.anz.com'
                'CTXAU201MEL0011.globaltest.anz.com CTXAU201MEL0018.globaltest.anz.com'
              else
                # global.anz.com
                'CTXAU001MEL0021.global.anz.com CTXAU001MEL0022.global.anz.com CTXAU002MEL0021.global.anz.com CTXAU002MEL0022.global.anz.com'
              end
    when '6.3', '10.0'
      value = nil
      begin
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent') do |regkey|
          value = regkey['ListofDDCs']
        end
      rescue
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent') do |regkey|
          value = regkey['ListofDDCs']
        end
      end
      value
    end
  end
end

# Agent Version Facter
Facter.add('citrix_agent_version') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    case Facter.value(:kernelmajversion)
    when '6.1'
      value = '6.5.0'
    when '6.3', '10.0'
      value = nil
      begin
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['BrokerVersion']
        end
      rescue
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['BrokerVersion']
        end
      end
      value
    end
  end
end

# Farm Name Facter
Facter.add('citrix_farm_name') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    case Facter.value(:kernelmajversion)
    when '6.1'
      value = 'GT XenApp 6.5'
    when '6.3', '10.0'
      value = nil
      begin
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['FarmName']
        end
      rescue
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['FarmName']
        end
      end
      value
    end
  end
end

# Idle Time out facter for avc_sec_04
Facter.add('maxidletime') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    value = nil
    begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
        value = regkey['MaxIdleTime']
      end
    rescue
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
        value = regkey['MaxIdleTime']
      end
    end
    value
  end
end

# RDS License Server Facter
Facter.add('rdsserver') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    value = nil
    begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
        value = regkey['LicenseServers']
      end
    rescue
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
        value = regkey['LicenseServers']
      end
    end
    value
  end
end
