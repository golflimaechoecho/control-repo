# list installed hotfixes (KBs) for Windows only
require 'json'
require 'open3'

Facter.add('installed_kb_hotfixes') do
  confine :kernel do |value|
    value == 'windows'
  end
  setcode do
    installed_kb_hash = {}

    # if powershell.exe is not in path may need to add extra logic to set
    ps_exec = "powershell.exe"
    ps_command = "Get-HotFix | Select-Object HotFixID, Description, InstalledBy, InstalledOn | ConvertTo-Json -Compress"
    stdout, stderr, status = Open3.capture3(ps_exec, "-Command", ps_command)

    # capture3 returns stdout as a string (representing an array of json hashes)
    # parse this string into json; convert to a single hash with hotfixid as keys
    hotfix_json = JSON.parse(stdout)

    hotfix_json.each do | eachkb |
      # get the HotFixID to use as key
      hotfixid = eachkb['HotFixID']
      # add hotfixid as key, set value to the hash (minus the HotFixID key)
      installed_kb_hash[hotfixid] = eachkb.delete_if { | key, value | key == 'HotFixID' }
    end

    installed_kb_hash
  end
end