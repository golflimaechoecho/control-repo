## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
# https://puppet.com/docs/puppet/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##

# Disable filebucket by default for all File resources:
# https://github.com/puppetlabs/docs-archive/blob/master/pe/2015.3/release_notes.markdown#filebucket-resource-no-longer-created-by-default
File { backup => false }

# determine datacentre based on list of networks defined in hiera
# note: this is topscope var not a fact so can't use on console - use to populate external fact?
# possible pitfalls/gotchas:
# - current example matches on primary interface network only
# - returns first match (ie: if more-specific match defined later it won't get there)
# - matching may need to be refined (and/or add validation to prevent input of bad networks)

$datacentre_networks = lookup('datacentre_networks', { 'merge' => 'hash', default_value => {}})

# index() requires puppet 6.x+; pick() requires stdlib
$dc_index =
  $datacentre_networks.index | String $dc, Array $dc_networks | {
    $facts['networking']['network'] in $dc_networks
  }
$datacentre = pick($dc_index, 'undefined_datacentre')


## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from the
# Puppet Enterprise console and External Node Classifiers (ENC's).
#
# For more on node definitions, see: https://puppet.com/docs/puppet/latest/lang_node_definitions.html
node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
}
