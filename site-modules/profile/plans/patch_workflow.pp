# plan to run patch workflow
#
# @param targets Targets to patch
# @param backup_method method to snapshot/backup (ie: commvault, nutanix, vmware)
# @param [Optional[Enum['hostname', 'name', 'uri']]] target_name_property
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
#
# @param [String[1]] vsphere_host
#   Hostname of the vSphere server that we're going to use to create snapshots via the API.
#
# @param [String[1]] vsphere_username
#   Username to use when authenticating with the vSphere API.
#
# @param [String[1]] vsphere_password
#   Password to use when authenticating with the vSphere API.
#
# @param [String[1]] vsphere_datacenter
#   Name of the vSphere datacenter to search for VMs under.
#
# @param [Boolean] vsphere_insecure
#   Flag to enable insecure HTTPS connections by disabling SSL server certificate verification.
# @param reconnect_timeout How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 180.
# @param lock_check_timeout How long (in seconds) to attempt to recheck before giving up. Defaults to 600.
# @param lock_retry_interval How long (in seconds) to wait between retries. Defaults to 5.
# @param fail_plan_on_errors Raise an error if any targets do not successfully unlock. Defaults to true.
# @param perform_reboot Whether to perform reboot or just print message (NOTE: this determines pre-patch reboot behaviour only; pe_patch may still initiate reboot depending on configuration). Defaults to true.
# @param dry_run Currently unused; could be used to determine whether to actually run. Defaults to false.
#
plan profile::patch_workflow (
  TargetSpec $targets,
  Optional[Enum['commvault', 'nutanix', 'vmware']] $backup_method = undef,
  Optional[Enum['hostname', 'name', 'uri']] $target_name_property = 'hostname',
  String[1] $vsphere_host       = get_targets($targets)[0].vars['vsphere_host'],
  String[1] $vsphere_username   = get_targets($targets)[0].vars['vsphere_username'],
  String[1] $vsphere_password   = get_targets($targets)[0].vars['vsphere_password'],
  String[1] $vsphere_datacenter = get_targets($targets)[0].vars['vsphere_datacenter'],
  Boolean $vsphere_insecure     = get_targets($targets)[0].vars['vsphere_insecure'],
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $lock_check_timeout = 600,
  Integer[0] $lock_retry_interval = 5,
  Boolean    $fail_plan_on_errors = true,
  Boolean    $perform_reboot = true,
  Boolean    $dry_run = false,
) {
  # Collect facts
  # note: facts plan fails on AIX, appears this is due to user facts from hardening/os_hardening
  run_plan(facts, targets => $targets, '_catch_errors' => true)

  # Commvault backup placeholder
  # where specified by parameter or physical hosts (is_virtual == false)
  $commvault_targets = get_targets($targets).filter | $target | {
    $backup_method == 'commvault' or $target.facts['is_virtual'] == false
  }

  out::message("commvault_targets is ${commvault_targets}")

  # Nutanix snapshot placeholder
  # where specified by parameter or by [fact TBD to show this is Nutanix]
  # TBD: check how this is represented by facts['virtual']/how differentiated from vmware
  # https://puppet.com/docs/puppet/6.18/core_facts.html#virtual
  $nutanix_targets = get_targets($targets).filter | $target | {
    $backup_method == 'nutanix' or $target.facts['virtual'] == 'nutanix'
  }

  out::message("nutanix_targets is ${nutanix_targets}")

  # vmware snapshot placeholder
  # for now assume vmware if it has not been picked up by commvault or nutanix targets
  $vmware_targets = get_targets($targets) - (get_targets($commvault_targets) + get_targets($nutanix_targets))
  out::message("vmware_targets is ${vmware_targets}")

  # List service status prior to patching for later comparison
  $services_before_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # run respective snapshot/backups based on commvault/nutanix/vmware
  run_plan('profile::commvault_placeholder', targets => $commvault_targets)
  run_plan('profile::nutanix_placeholder', targets => $nutanix_targets)

  # placeholder for patching::snapshot_vmware, replace once firewall rules in place/confirmed working
  run_plan('profile::snapshot_placeholder', targets              => $vmware_targets,
                                            target_name_property => $target_name_property,
                                            vsphere_host         => $vsphere_host,
                                            vsphere_username     => $vsphere_username,
                                            vsphere_password     => $vsphere_password,
                                            vsphere_datacenter   => $vsphere_datacenter,
                                            vsphere_insecure     => $vsphere_insecure
  )
  #  #run_plan('patching::snapshot_vmware', targets              => $vmware_targets,
  #                                      action               => 'create',
  #                                      target_name_property => $target_name_property,
  #                                      vsphere_host         => $vsphere_host,
  #                                      vsphere_username     => $vsphere_username,
  #                                      vsphere_password     => $vsphere_password,
  #                                      vsphere_datacenter   => $vsphere_datacenter,
  #                                      vsphere_insecure     => $vsphere_insecure
  #)

  if $perform_reboot and ( ! $dry_run ) {
    run_plan('reboot', targets => $targets, reconnect_timeout => $reconnect_timeout)
  } else {
    out::message("Skipping pre-patch reboot as perform_reboot false or dry_run ${dry_run} specified")
  }

  # insert additional delay/sleep before running pe_patch, as pe_patch fact
  # generation runs on boot and can end up locking itself out
  run_plan('profile::pe_patch_lock_check', targets => $targets, lock_check_timeout => $lock_check_timeout)

  if $dry_run {
    out::message("dry_run ${dry_run}: otherwise pe_patch::patch_server would be run here")
  } else {
    $patch_result = run_task('pe_patch::patch_server', $targets, reboot => 'patched')
  }

  $services_after_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
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
        $post_result['service'][$post_service_name]['ensure'] != $pre_result['service'][$post_service_name]['ensure']
      }
    }
    # if any of these are non-empty, add to results (if all are empty this means no changes)
    unless ( $changed_post_patch.empty and $missing_post_patch.empty and $new_post_patch.empty ) {
      $memo + { $target_name => {
                  'changed_post_patch' => $changed_post_patch,
                  'absent_post_patch'  => $missing_post_patch,
                  'new_post_patch'     => $new_post_patch,
                }
              }
    }
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
