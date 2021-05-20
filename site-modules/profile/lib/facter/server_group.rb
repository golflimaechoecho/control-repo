# server_group custom fact
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
        # rubocop:disable Layout/LineLength
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$DC = #{dc};if($dc -contains $env:computername) { $servergroup = 'Citrix Delivery Controller' } elseif((get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*') | Where-Object { $_.DisplayName -like 'Citrix Licensing' }) { $servergroup = 'Citrix License Server' } elseif((get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*') | Where-Object { $_.DisplayName -like '*Citrix XenApp*' }) { $servergroup = 'Citrix XenApp Member' } else { $servergroup = 'Citrix Utility Server' };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
        # rubocop:enable Layout/LineLength
      rescue
        value = 'Citrix Server Group Error'
      end
      value.chomp
    when '6.3', '10.0'
      begin
        value = nil
        psexec = 'powershell.exe'
        # rubocop:disable Layout/LineLength
        value = %x{#{psexec} -ExecutionPolicy ByPass -Command "$Apps = (get-itemproperty 'HKLM:Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').displayname; $apps += (get-itemproperty 'HKLM:Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*').DisplayName; $apps = $apps | sort-object; switch -Wildcard ($apps) { 'Citrix Licensing' { $servergroup = 'Citrix License Server'; break } 'Citrix Director' { $servergroup = 'Citrix Director Server'; break } '*Provisioning Server x64*' { $servergroup = 'Citrix PVS Server'; break } '*Citrix Provisioning Server*' { $servergroup = 'Citrix PVS Server'; break } 'Citrix StoreFront' { $servergroup = 'Citrix StoreFront Server'; break } 'Citrix Broker Service' { $servergroup = 'Citrix Delivery Controller'; break } '*Virtual Delivery Agent*' { $servergroup = 'Citrix XenApp Member'; break } '*Citrix Workspace Environment Management Infrastructure Services*' { $servergroup = 'Citrix WEM Server'; break } Default { $servergroup = 'Citrix Utility Server'} };$hname = $env:computername;if($servergroup -eq 'Citrix Utility Server') { if($hname -match 'RDS' -or $hname -match 'DHC' -or $hname -match 'CTX') { $servergroup = 'Citrix Utility Server' } else {$servergroup = 'Windows Server' } };return $servergroup"}
        # rubocop:enable Layout/LineLength
      rescue
        value = 'Citrix Server Group Error'
      end
      value.chomp
    end
  end
end
