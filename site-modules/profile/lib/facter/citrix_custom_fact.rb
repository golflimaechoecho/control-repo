require 'json'

=begin
Facter.add('citrix_delivery_controller') do
  confine :server_group => :"Citrix XenApp Member"
  setcode do
    case Facter.value(:kernelmajversion)
    when "6.1"
      begin
        value = nil
        psexec = if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
          "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
        elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
         "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
        else
         'powershell.exe'
        end
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*') | Where-Object { $_.DisplayName -like 'Citrix Licensing' }) { $servergroup = 'Citrix License Server' } elseif((get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*') | Where-Object { $_.DisplayName -like '*Citrix XenApp*' }) { $servergroup = 'Citrix XenApp Member' } else { $servergroup = 'Citrix Utility Server' };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
      rescue
        value = "Citrix Server Group Error"
      end
      value.chomp
    when "6.3"
      begin
        value = nil
        psexec = 'powershell.exe'
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$Apps = (get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').displayname; $apps += (get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').DisplayName; $apps = $apps | sort-object; switch -Wildcard ($apps) { 'Citrix Licensing' { $servergroup = 'Citrix License Server'; break } 'Citrix Director' { $servergroup = 'Citrix Director Server'; break } '*Provisioning Services x64*' { $servergroup = 'Citrix PVS Server'; break } 'Citrix StoreFront' { $servergroup = 'Citrix StoreFront Server'; break } 'Citrix Broker Service' { $servergroup = 'Citrix Delivery Controller'; break } '*Virtual Delivery Agent*' { $servergroup = 'Citrix XenApp Member'; break } Default { $servergroup = 'Citrix Utility Server'} };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
      rescue
        value = "Citrix Server Group Error"
      end
      value.chomp
    when "10.0"
      begin
        value = nil
        psexec = 'powershell.exe'
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$Apps = (get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').displayname; $apps += (get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').DisplayName; $apps = $apps | sort-object; switch -Wildcard ($apps) { 'Citrix Licensing' { $servergroup = 'Citrix License Server'; break } 'Citrix Director' { $servergroup = 'Citrix Director Server'; break } '*Provisioning Services x64*' { $servergroup = 'Citrix PVS Server'; break } 'Citrix StoreFront' { $servergroup = 'Citrix StoreFront Server'; break } 'Citrix Broker Service' { $servergroup = 'Citrix Delivery Controller'; break } '*Virtual Delivery Agent*' { $servergroup = 'Citrix XenApp Member'; break } Default { $servergroup = 'Citrix Utility Server'} };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
      rescue
        value = "Citrix Server Group Error"
      end
      value.chomp
    end
  end
end
=end

# License Server Facter
Facter.add('citrix_license_server') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    case Facter.value(:kernelmajversion)
    when '6.1'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\Wow6432node\Citrix\Licensing') do |regkey|
          value = regkey['MFCM_LSHostName']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Policies\Citrix\IMA\Licensing') do |regkey|
          value = regkey['LicenseServerHostName']
        end
      end
      value
    when '6.3'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['LicenseServerName']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['LicenseServerName']
        end
      end
      value
    when '10.0'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['LicenseServerName']
        end
      rescue
        value = nil
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
    when '6.3'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent') do |regkey|
          value = regkey['ListofDDCs']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent') do |regkey|
          value = regkey['ListofDDCs']
        end
      end
      value
    when '10.0'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent') do |regkey|
          value = regkey['ListofDDCs']
        end
      rescue
        value = nil
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
    when '6.3'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['BrokerVersion']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['BrokerVersion']
        end
      end
      value
    when '10.0'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['BrokerVersion']
        end
      rescue
        value = nil
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
    when '6.3'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['FarmName']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['FarmName']
        end
      end
      value
    when '10.0'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
          value = regkey['FarmName']
        end
      rescue
        value = nil
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
    case Facter.value(:kernelmajversion)
    when '6.1'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
          value = regkey['MaxIdleTime']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
          value = regkey['MaxIdleTime']
        end
      end
      value
    when '6.3'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
          value = regkey['MaxIdleTime']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
          value = regkey['MaxIdleTime']
        end
      end
      value
    when '10.0'
      begin
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
          value = regkey['MaxIdleTime']
        end
      rescue
        value = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
          value = regkey['MaxIdleTime']
        end
      end
      value
    end
  end
end

# RDS License Server Facter
Facter.add('rdsserver') do
  confine server_group: 'Citrix XenApp Member'
  setcode do
    begin
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
        value = regkey['LicenseServers']
      end
    rescue
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services') do |regkey|
        value = regkey['LicenseServers']
      end
    end
    value
  end
end

# Windows Update Server Facter
Facter.add('winupdateserver') do
  setcode do
    begin
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate') do |regkey|
        value = regkey['WUServer']
      end
    rescue
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate') do |regkey|
        value = regkey['WUServer']
      end
    end
    value
  end
end

=begin
#Machine Catalog Facter
Facter.add('citrix_machine_catalog') do
  confine :osfamily => :windows
  setcode do
    begin
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
        value = regkey['DesktopCatalogName']
      end
      value
    rescue
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
        value = regkey['DesktopCatalogName']
      end
      value
    end
  end
end
#Delivey Group Facter
Facter.add('citrix_delivery_group') do
  confine :osfamily => :windows
  setcode do
    begin
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Citrix\VirtualDesktopAgent\State') do |regkey|
        value = regkey['DesktopGroupName']
      end
      value
    rescue
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432\Citrix\VirtualDesktopAgent\State') do |regkey|
        value = regkey['DesktopGroupName']
      end
      value
    end
  end
end
Facter.add('server_group') do
  confine :osfamily => :windows
  setcode do
    begin
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName') do |regkey|
      value = regkey['ComputerName']
      end
      if value.include? "CTX"
        value = "Citrix Server"
      else
        value = "Windows Server"
      end
    value
    rescue
      value = "Hostname Error"
    end
    value
  end
end
=end
