#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'

# most platforms have puppet in path; however rhel6 seems to need help finding it on occasion
# for now let windows work out the path itself rather than messing/mixing slashes
if (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  puppet_cmd = 'puppet'
  #puppet_cmd = "#{ENV['programfiles']}/Puppet Labs/Puppet/bin/puppet"
else
  puppet_cmd = '/opt/puppetlabs/puppet/bin/puppet'
end

service_output = %x[#{puppet_cmd} resource service --to_yaml]

puts JSON.pretty_generate(YAML.load(service_output))
