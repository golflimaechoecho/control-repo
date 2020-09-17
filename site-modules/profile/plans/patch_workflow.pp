# @summary plan to run patch workflow
#
# Uses pe_patch to perform patching on Linux and Windows
#
# @param [TargetSpec] targets
#   Targets to patch
#
# @param [Optional[Enum['commvault', 'nutanix', 'vmware']]] backup_method
#   Method to perform snapshot/backup
#
# @param [Optional[Enum['hostname', 'name', 'uri', 'upcase_hostname']]] target_name_property
#   Determines what property on the Target object will be used as the VM name when
#   mapping the Target to a VM in vSphere.
#
#    - `uri` : use the `uri` property on the Target. This is preferred because
#       If you specify a list of Targets in the inventory file, the value shown in that
#       list is set as the `uri` and not the `name`, in this case `name` will be `undef`.
#    - `name` : use the `name` property on the Target, this is not preferred because
#       `name` is usually a short name or nickname.
#    - `hostname`: use the `hostname` value to use host component of `uri` property on the Target
#      this can be useful if VM name doesn't include domain name
#    - `upcase_hostname`: uppercase the `host component of `uri` property on the Target as
#      workaround where VMware names are in uppercase. Does not cater for hosts with mixedcase names
#
# @param [Optional[String[1]]] vsphere_host
#   Hostname of the vSphere server that we're going to use to create snapshots via the API.
#
# @param [Optional[String[1]]] vsphere_username
#   Username to use when authenticating with the vSphere API.
#
# @param [Optional[String[1]]] vsphere_password
#   Password to use when authenticating with the vSphere API.
#
# @param [Optional[String[1]]] vsphere_datacenter
#   Name of the vSphere datacenter to search for VMs under.
#
# @param [Boolean] vsphere_insecure
#   Flag to enable insecure HTTPS connections by disabling SSL server certificate verification.
#
# @param [Optional[String[1]]] snapshot_name
#   Name of the snapshot
#
# @param [Optional[TargetSpec]] nutanix_cvm
#   Nutanix CVM to use to create snapshots
#
# @param Optional[String[1]] commvault_api_server
#   Hostname/FQDN of the CommVault API server
#
# @param Optional[Integer[0, 65535]] commvault_api_port
#   Port to use to connect to CommVault API server
#
# @param [Integer[0]] reconnect_timeout
#   How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 180.
#
# @param [Integer[0]] pe_patch_lock_check_timeout
#   How long (in seconds) to attempt to recheck for pe_patch lock before giving up. Defaults to 600.
#
# @param [Boolean] perform_backup
#   Whether to perform backup or just print message. Defaults to true
#
# @param [Boolean] perform_reboot
#   Whether to perform reboot or just print message (NOTE: this determines
#   pre-patch reboot behaviour only; pe_patch may still initiate reboot depending
#   on pe_patch configuration). Defaults to true.
#
# @param [Boolean] dry_run
#   Set to true to dry run only, false to actually run. Defaults to false.
#
plan profile::patch_workflow (
  TargetSpec $targets,
  Optional[Enum['commvault', 'nutanix', 'vmware']] $backup_method = undef,
  Optional[Enum['hostname', 'name', 'uri', 'upcase_hostname']] $target_name_property = 'upcase_hostname',
  Optional[String[1]] $vsphere_host       = get_targets($targets)[0].vars['vsphere_host'],
  Optional[String[1]] $vsphere_username   = get_targets($targets)[0].vars['vsphere_username'],
  Optional[String[1]] $vsphere_password   = get_targets($targets)[0].vars['vsphere_password'],
  Optional[String[1]] $vsphere_datacenter = get_targets($targets)[0].vars['vsphere_datacenter'],
  Optional[Boolean]   $vsphere_insecure   = get_targets($targets)[0].vars['vsphere_insecure'],
  Optional[String[1]] $snapshot_name      = undef,
  Optional[String[1]] $commvault_api_server = 'dccebrssq01.w2k.bnm.gov.my',
  Optional[Integer[0, 65535]] $commvault_api_port = 81,
  Optional[TargetSpec] $nutanix_cvm = undef,
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $pe_patch_lock_check_timeout = 600,
  Boolean    $perform_backup = true,
  Boolean    $perform_reboot = true,
  Boolean    $dry_run = false,
) {
  # Collect facts
  # note: facts plan fails on AIX, appears this is due to user facts from hardening/os_hardening
  without_default_logging() || {
    run_plan(facts, targets => $targets, '_catch_errors' => true)
  }

  $windows_targets = get_targets($targets).filter | $target | {
    $target.facts['os']['family'] == 'windows'
  }

  $redhat_targets = get_targets($targets).filter | $target | {
    $target.facts['os']['family'] == 'RedHat'
  }

  $physical_targets = get_targets($targets).filter | $target | {
    $target.facts['is_virtual'] == false
  }

  # Commvault backup placeholder
  # where specified by parameter or physical hosts ($facts['is_virtual'] == false)
  $commvault_targets = get_targets($targets).filter | $target | {
    $backup_method == 'commvault' or $target.facts['is_virtual'] == false
  }

  # Nutanix snapshot placeholder
  # Run where specified by parameter or when $facts['virtual'] == 'hyperv'
  # https://puppet.com/docs/puppet/6.18/core_facts.html#virtual
  $nutanix_targets = get_targets($targets).filter | $target | {
    $backup_method == 'nutanix' or $target.facts['virtual'] == 'hyperv'
  }

  # vmware snapshot placeholder
  # for now assume vmware if it has not been picked up by commvault or nutanix targets
  $vmware_targets = get_targets($targets) - (get_targets($commvault_targets) + get_targets($nutanix_targets))

  # List service status prior to patching for later comparison
  $services_before_patching = without_default_logging() || {
    run_task('profile::check_services', $targets, '_catch_errors' => true)
  }

  # run respective snapshot/backups based on commvault/nutanix/vmware
  # unless we have specified to skip backup ($perform_backup == false)
  if $perform_backup {
    if ! get_targets($physical_targets).empty {
      run_plan('profile::rhel_physical_backup_placeholder', targets => $physical_targets)
    }
    if ! get_targets($commvault_targets).empty {
      run_plan('profile::commvault_placeholder', targets => $commvault_targets)
    }

    if ! get_targets($nutanix_targets).empty {
      if $nutanix_cvm == undef {
        fail_plan('nutanix_cvm is required to perform nutanix snapshot',
          'bolt/patch_workflow-failed', {
            action     => 'plan/patch_workflow',
            result_set => $nutanix_targets,
        })
      }

      run_plan('profile::nutanix_placeholder', controller_vm    => $nutanix_cvm,
                                                targetvm        => $nutanix_targets,
                                                action          => 'create',
                                                snapshot_name   => $snapshot_name,
                                                noop            => true,
                                                '_catch_errors' => true
      )
    }

    if ! get_targets($vmware_targets).empty {
      # pass noop based on whether this is dry_run
      if $dry_run {
        $snapshot_vmware_noop = true
        out::message("Dry run: run snapshot_vmware here")
      } else {
        $snapshot_vmware_noop = false
      }
      run_plan('patching::snapshot_vmware', targets              => $vmware_targets,
                                            action               => 'create',
                                            target_name_property => $target_name_property,
                                            vsphere_host         => $vsphere_host,
                                            vsphere_username     => $vsphere_username,
                                            vsphere_password     => $vsphere_password,
                                            vsphere_datacenter   => $vsphere_datacenter,
                                            vsphere_insecure     => $vsphere_insecure,
                                            snapshot_name        => $snapshot_name,
                                            noop                 => $snapshot_vmware_noop
      )
    }
  } else {
    out::message("Backup/snapshot not run as perform_backup set to ${perform_backup}")
  }

  # After snapshot/backup, before reboot

  # Windows: remove tmpfiles - set noop true for now as still testing
  if ! get_targets($windows_targets).empty {
    out::message("Windows: recursively remove *.tmp files")
    run_plan('profile::windows_tidy_tmpfiles', $windows_targets, noop => true, '_catch_errors' => true)
  }

  if $perform_reboot and ( ! $dry_run ) {
    run_plan('reboot', targets => $targets, reconnect_timeout => $reconnect_timeout)
  } else {
    out::message("Skipping pre-patch reboot as perform_reboot false or dry_run ${dry_run} specified")
  }

  # insert additional delay/sleep before running pe_patch, as pe_patch fact
  # generation runs on boot and can end up locking itself out
  run_plan('profile::pe_patch_lock_check', targets => $targets, lock_check_timeout => $pe_patch_lock_check_timeout)

  if $dry_run {
    out::message("dry_run ${dry_run}: otherwise pe_patch::patch_server would be run here")
  } else {
    $patch_result = run_task('pe_patch::patch_server', $targets, reboot => 'patched')
  }

  # Post-patch
  run_plan('profile::copy_eventlog_placeholder', targets => $windows_targets, '_catch_errors' => true)

  $services_after_patching = without_default_logging() || {
    run_task('profile::check_services', $targets, '_catch_errors' => true)
  }

  # check if any services from before patching are not running
  $service_changes = $services_before_patching.reduce({}) | $memo, $pre_result | {
    $target_name = $pre_result.target().name()
    $post_result = $services_after_patching.find($target_name)

    # repetitive loops as reduce() didn't want to create nested hash
    # service in pre-results but not in post-results
    $missing_post_patch = $pre_result['service'].filter | $pre_service_name, $pre_service_values | {
      ! $pre_service_name in $post_result['service'].keys()
    }
    # service in post-results but not in pre-results
    $new_post_patch = $post_result['service'].filter | $post_service_name, $post_service_values | {
      ! $post_service_name in $pre_result['service'].keys()
    }
    # use post_result for changed_services so it will display current (post-patch) state
    $changed_post_patch = $post_result['service'].filter | $post_service_name, $post_service_values | {
      if $post_service_name in $pre_result['service'].keys() {
        # ensure (running/stopped) is not in the same state as prior to patching
        # restrict check to automatic services (enable = true) as agreed with CBM
        # NOTE: if service was stopped prior to patching then didn't start on
        # boot this would not be recorded as the statuses would match
        $post_result['service'][$post_service_name]['enable'] == 'true' and ( $post_result['service'][$post_service_name]['ensure'] != $pre_result['service'][$post_service_name]['ensure'] )
      }
    }
    # To only check if enabled services were running, a separate check could be
    # added and the results added to memo. example below (not added to memo yet)
    #$enabled_not_running = $post_result['service'].filter | $post_service_name, $post_service_values | {
    #  $post_result['service'][$post_service_name]['enable'] == 'true' and $post_result['service'][$post_service_name]['ensure'] != 'running'
    #}

    # if any of these are non-empty, add to results (if all are empty this means no changes)
    if ( $changed_post_patch.empty and $missing_post_patch.empty and $new_post_patch.empty ) {
      # if there are no changes don't add anything
      $target_change_hash = {}
    } else {
      $target_change_hash = { $target_name => {
                                'changed_post_patch' => $changed_post_patch,
                                'absent_post_patch'  => $missing_post_patch,
                                'new_post_patch'     => $new_post_patch,
                              }
                            }
    }
    $memo + $target_change_hash
  }

  # hash of changes to return
  # for now set to service_changes if not empty
  # potentially add package, other checks that are added
  if ! $service_changes.empty {
    $changes = { 'service_changes' => $service_changes }
  } else {
    $changes = {}
  }

  if ! $changes.empty {
    return($changes)
  } else {
    return()
  }
}
