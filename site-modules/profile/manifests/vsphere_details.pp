# @summary write vsphere_details to external fact file based on hiera
# this is somewhat backwards as looking up details from hiera to set the fact
#
# Below assumes default details are defined/available via hiera, otherwise this will fail
class profile::vsphere_details (
  $vsphere_datacenter,
  $vsphere_host,
){
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
    content => epp("${module_name}/vsphere_details.epp", { 'vsphere_datacenter' => $vsphere_datacenter, 'vsphere_host' => $vsphere_host }),
    *       => $fact_file_attributes,
  }
}
