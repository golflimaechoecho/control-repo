# Custom Facter To classify
# OS Product Name
Facter.add('windows_product_name') do
  confine osfamily: 'windows'
  setcode do
    begin
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Microsoft\Windows NT\CurrentVersion') do |regkey|
        value = regkey['ProductName']
      end
      value
    rescue
      nil
    end
  end
end
# Servergroup Facter
Facter.add('server_group') do
  confine osfamily: 'windows'
  setcode do
    case Facter.value(:kernelmajversion)
    when '6.1'
      begin
        domain = Facter.value(:networking)['domain']
        dc = case domain
             when 'globaltest.anz.com'
               %('CTXAU201MEL0011', 'CTXAU201MEL0018')
             else
               # global.anz.com
               %('CTXAU001MEL0021', 'CTXAU001MEL0022', 'CTXAU002MEL0021', 'CTXAU002MEL0022')
             end
        value = nil
        psexec = if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                   "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
                 elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                   "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
                 else
                   'powershell.exe'
                 end
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$DC = #{dc};if($dc -contains $env:computername) { $servergroup = 'Citrix Delivery Controller' } elseif((get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*') | Where-Object { $_.DisplayName -like 'Citrix Licensing' }) { $servergroup = 'Citrix License Server' } elseif((get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*') | Where-Object { $_.DisplayName -like '*Citrix XenApp*' }) { $servergroup = 'Citrix XenApp Member' } else { $servergroup = 'Citrix Utility Server' };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
      rescue
        value = 'Citrix Server Group Error'
      end
      value.chomp
    when '6.3'
      begin
        value = nil
        psexec = 'powershell.exe'
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$Apps = (get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').displayname; $apps += (get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').DisplayName; $apps = $apps | sort-object; switch -Wildcard ($apps) { 'Citrix Licensing' { $servergroup = 'Citrix License Server'; break } 'Citrix Director' { $servergroup = 'Citrix Director Server'; break } '*Provisioning Server x64*' { $servergroup = 'Citrix PVS Server'; break } '*Citrix Provisioning Server*' { $servergroup = 'Citrix PVS Server'; break } 'Citrix StoreFront' { $servergroup = 'Citrix StoreFront Server'; break } 'Citrix Broker Service' { $servergroup = 'Citrix Delivery Controller'; break } '*Virtual Delivery Agent*' { $servergroup = 'Citrix XenApp Member'; break } '*Citrix Workspace Environment Management Infrastructure Services*' { $servergroup = 'Citrix WEM Server'; break } Default { $servergroup = 'Citrix Utility Server'} };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
      rescue
        value = 'Citrix Server Group Error'
      end
      value.chomp
    when '10.0'
      begin
        value = nil
        psexec = 'powershell.exe'
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$Apps = (get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').displayname; $apps += (get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').DisplayName; $apps = $apps | sort-object; switch -Wildcard ($apps) { 'Citrix Licensing' { $servergroup = 'Citrix License Server'; break } 'Citrix Director' { $servergroup = 'Citrix Director Server'; break } '*Provisioning Server x64*' { $servergroup = 'Citrix PVS Server'; break } '*Citrix Provisioning Server*' { $servergroup = 'Citrix PVS Server'; break } 'Citrix StoreFront' { $servergroup = 'Citrix StoreFront Server'; break } 'Citrix Broker Service' { $servergroup = 'Citrix Delivery Controller'; break } '*Virtual Delivery Agent*' { $servergroup = 'Citrix XenApp Member'; break } '*Citrix Workspace Environment Management Infrastructure Services*' { $servergroup = 'Citrix WEM Server'; break } Default { $servergroup = 'Citrix Utility Server'} };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
      rescue
        value = 'Citrix Server Group Error'
      end
      value.chomp
    end
  end
end
# Windows privileged users custom facter
require 'json'
Facter.add('windows_admin_users') do
  confine kernel: 'windows'
  setcode do
    powershell = 'powershell.exe'
    query = "$Ms = net localgroup administrators | where {$_ -AND $_ -notmatch 'command completed successfully'} | select -skip 4;foreach($m in $Ms){$users += $M+' , '}; return $Users"
    response = Facter::Util::Resolution.exec(%(#{powershell} -command "#{query}"))
    value = if response
              response
            else
              error
            end
    value
  end
end
Facter.add('windows_power_users') do
  confine kernel: 'windows'
  setcode do
    powershell = 'powershell.exe'
    query = "$Ms = net localgroup 'Power Users' | where {$_ -AND $_ -notmatch 'command completed successfully'} | select -skip 4 ;foreach($m in $Ms){$users += $M+' , '}; return $Users"
    response = Facter::Util::Resolution.exec(%(#{powershell} -command "#{query}"))
    value = if response
              response
            else
              error
            end
    value
  end
end
Facter.add('windows_rdp_users') do
  confine kernel: 'windows'
  setcode do
    powershell = 'powershell.exe'
    query = "$Ms = net localgroup 'Remote Desktop Users' | where {$_ -AND $_ -notmatch 'command completed successfully'} | select -skip 4 ;foreach($m in $Ms){$users += $M+' , '}; return $Users"
    response = Facter::Util::Resolution.exec(%(#{powershell} -command "#{query}"))
    value = if response
              response
            else
              error
            end
    value
  end
end
