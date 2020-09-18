# @summary profile to add installedkb_external external fact
#
# @ref https://puppet.com/docs/puppet/latest/external_facts.html
#
class profile::windows::installedkb {

  # installedkb fact applicable to windows only; fail if os.family is not windows
  unless $facts['os']['family'] == 'windows' {
    fail("profile::windows::installedkb is not supported on ${facts['os']['family']}")
  }

  $extfactdir = 'C:/ProgramData/PuppetLabs/facter/facts.d'
  $factfile = 'installedkb_external.ps1'

  # in this case we are not explicitly defining the parent directory/directories
  # as we "know"/assume they exist from the installation and we don't want to
  # introduce potential duplicates/conflicts

  # RedHat, AIX should also set mode, owner, group; Windows doesn't care as much
  file { 'installedkb_externalfact':
    ensure => absent,
    path   => "${extfactdir}/${factfile}",
    source => "puppet:///modules/${module_name}/${factfile}",
  }
}
