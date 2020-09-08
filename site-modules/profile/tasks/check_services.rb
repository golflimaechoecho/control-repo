#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'

# Set path to puppet_cmd based on whether windows or not
if (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  puppet_cmd = "#{ENV['programfiles']}/Puppet Labs/Puppet/bin/puppet"
else
  puppet_cmd = '/opt/puppetlabs/puppet/bin/puppet'
end

service_output = %x[#{puppet_cmd} resource service --to_yaml]

puts JSON.pretty_generate(YAML.load(service_output))
