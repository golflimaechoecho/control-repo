# @summary dummy profile for pe_patch
#
# This is for illustration/example only, not intended for production in its current form
#
# use include ::pe_patch with attributes set via hiera
# rather than using resource-like declaration (class { 'pe_patch': ... })
# Note: {pre,post}_patching_scriptpath require PE 2019.8.5
# earlier PE2019.8 uses pre_patching_command, and does not have post_
# https://puppet.com/docs/pe/2019.8/release_notes_pe.html#run-a-command-after-patching-nodes
#
# example hiera:
# profile::pe_patch::pe_patch_scriptdir: '/opt/pe_patch'
# pe_patch::pre_patching_scriptpath: '/path/to/pre_script'
# pe_patch::post_patching_scriptpath: '/path/to/post_script'
#
class profile::pe_patch (
  Stdlib::Absolutepath $pe_patch_scriptdir = '/opt/pe_patch',
){
  include ::pe_patch

  case $facts['os']['family'] {
    'redhat': {
      # continue
      case $facts['os']['release']['major'] {
        # rhel5 and rhel6 require plugin for security patch reporting
        # https://access.redhat.com/solutions/10021
        # provided as example; hosts may already have plugin installed via build/other profiles
        '5': {
          package { 'yum-security':
            ensure => installed,
          }
        }
        '6': {
          package { 'yum-plugin-security':
            ensure => installed,
          }
        }
        default: {
          # No action for rhel7/8, security plugin already part of yum
        }
      }

      $pre_patching_scriptpath = "${pe_patch_scriptdir}/pre_pe_patch"
      $post_patching_scriptpath = "${pe_patch_scriptdir}/post_pe_patch"

      file { $pe_patch_scriptdir:
        ensure => directory,
      }

      # have not set up any dependencies as technically these only need to exist/be
      # in place when pe_patch::patch_server task is run
      file { $pre_patching_scriptpath:
        ensure => absent,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => "puppet:///modules/${module_name}/profile/pre_pe_patch",
      }

      file { $post_patching_scriptpath:
        ensure => absent,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => "puppet:///modules/${module_name}/profile/post_pe_patch",
      }

      # non-standard/custom attempt to test post-patch post-reboot script
      # illustration only - this may end up being too convoluted for ongoing use
      # this will execute on reboot only (so if pe_patch::patch_server is run
      # with reboot = never the timing may get strange)
      # Note: this assumes unmanaged cron resources are NOT being purged
      $post_patching_post_reboot_scriptpath = "${pe_patch_scriptdir}/post_pe_patch_post_reboot"

      file { $post_patching_post_reboot_scriptpath:
        ensure => absent,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => "puppet:///modules/${module_name}/profile/post_pe_patch_post_reboot",
      }
    }
    'windows': {
      # no platform specific steps yet
    }
    default: {
      fail("profile::pe_patch not supported for ${facts['os']['family']} yet")
    }
  }
}
