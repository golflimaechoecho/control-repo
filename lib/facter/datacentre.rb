# determine datacentre based on lists of networks
# possible pitfalls/gotchas:
# - new networks need to be added manually
# - current example matches on primary interface network only
# - returns first match
# - matching may need to be refined (and/or add validation to prevent input of bad networks)

Facter.add('datacentre') do
  setcode do
    ### define datacentre - network mappings here
    datacentre_networks = {
      "dc1" => [ "10.1.0.0", "10.2.0.0", "10.3.0.0" ],
      "dc2" => [ "10.10.0.0", "10.20.0.0", "10.30.0.0" ],
      "dc3" => [ "10.10.5.0", "10.20.5.0", "10.30.5.0" ],
      "dc4" => [ "10.1.1.0", "10.2.2.0", "10.3.3.0" ],
      "platform9" => [ "192.168.0.0" ]
    }
    ### end datacentre - network mappings

    dc_hash = datacentre_networks.select {|dc, networks| networks.include?(Facter.value(:networking)['network']) }
    if dc_hash.empty?
      datacentre = 'undefined_dc'
    else
      datacentre = dc_hash.keys[0]
    end
  end
end
