# list installed hotfixes (KBs) for Windows only
require 'open3'

Facter.add('installed_kb_hotfixes') do
  confine :kernel do |value|
    value == 'windows'
  end
  setcode do
    installed_kb_hash = {}
    # below outputs an array; convert to a hash with the hotfixid as keys
    stdout, stderr, status = Open3.capture3("Get-HotFix | Select-Object HotFixID, Description, InstalledBy, InstalledOn | ConvertTo-Json")
    stdout.each do | eachkb |
      # get the HotFixID to use as key
      hotfixid = eachkb['HotFixID']
      # add hotfixid as key, set value to the hash (minus the HotFixID key)
      installed_kb_hash[hotfixid] = eachkb.delete('HotFixID')
    end
    installed_kb_hash
  end
end
