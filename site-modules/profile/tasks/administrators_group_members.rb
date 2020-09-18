#!/opt/puppetlabs/puppet/bin/ruby
# List members of Administrators group on Windows
require 'rbconfig'
require 'json'
require 'yaml'
require 'open3'

# most platforms have puppet in path; however rhel6 seems to need help finding it on occasion
# for now let windows work out the path itself rather than messing/mixing slashes
if (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  #puppet_cmd = "#{ENV['programfiles']}/Puppet Labs/Puppet/bin/puppet"
  puppet_cmd = 'puppet'
  members_stdout, stderr, status = Open3.capture3("#{puppet_cmd} resource group Administrators --to_yaml")
  members_json = JSON.generate(YAML.load(members_stdout))
  puts members_json
  members_json.each do | groupdef |
    puts groupdef['Administrators']['members']
  end
else
  puts 'This task is only supported on Windows'
end
