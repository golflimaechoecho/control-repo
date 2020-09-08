#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'yaml'

service_output = %x[puppet resource service --to_yaml]

puts JSON.pretty_generate(YAML.load(service_output))
