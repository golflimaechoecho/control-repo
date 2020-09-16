# (Windows only) list members in Administrators group
require 'json'
require 'open3'

Facter.add('administrators_group_members') do
  confine :kernel do |value|
    value == 'windows'
  end
  setcode do
    administrators_members = []

    # if powershell.exe is not in path may need to add extra logic to set
    ps_exec = 'powershell.exe'
    ps_command = 'Get-LocalGroupMember -Group "Administrators" | Select-Object Name |ConvertTo-Json -Compress'
    stdout, stderr, status = Open3.capture3(ps_exec, "-Command", ps_command)

    # capture3 returns stdout as a string (representing an array of json hashes)
    # parse this string into json; convert to an array of member names
    members_json = JSON.parse(stdout)

    members_json.each do | memberjson |
      # get the Name key
      member = memberjson['Name']
      # add name to members array
      administrators_members.push(member)
    end

    administrators_members
  end
end
