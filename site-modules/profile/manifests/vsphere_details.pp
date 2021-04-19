# @summary write out vsphere details to external fact file
# this is somewhat backwards as looking up details from hiera to set the fact
class profile::vsphere_details {
  $vsphere_servers = lookup('profile::pe_patch::vsphere_servers')
  $vsphere_host = lookup('profile::pe_patch::vsphere_host')

  if $vsphere_host in $vsphere_servers {
   # external fact directories: https://puppet.com/docs/puppet/latest/external_facts.html
    case $facts['os']['family'] {
      'windows': {
        $extfactdir = 'C:/ProgramData/PuppetLabs/facter/facts.d'
        $fact_file_attributes = {}
      }
      default: {
        $extfactdir = '/etc/puppetlabs/facter/facts.d'
        $fact_file_attributes = {
          'owner' => 'root',
          'group' => 'root',
          'mode'  => '0644',
        }
      }
    }

    # ensure parent directories created - dirname() from stdlib
    file { [ dirname($extfactdir), $extfactdir ]:
      ensure => directory,
    }

    file { "${extfactdir}/vsphere_details.yaml":
      ensure  => file,
      content => epp("${module_name}/vsphere_details.epp", { 'vsphere_host' => $vsphere_host, 'vsphere_details' => $vsphere_servers[$vsphere_host] }),
      *       => $fact_file_attributes,
    }
  } else {
    fail("Unable to find specified vsphere_host ${vsphere_host} for ${trusted['certname']}")
  }
}
