# plan to run patch workflow
#
# @param targets Targets to patch
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
#
plan profile::patch_workflow (
  TargetSpec $targets,
  Optional[Enum['hostname', 'name', 'uri']] $target_name_property = undef,
  String[1] $vsphere_host       = get_targets($targets)[0].vars['vsphere_host'],
  String[1] $vsphere_username   = get_targets($targets)[0].vars['vsphere_username'],
  String[1] $vsphere_password   = get_targets($targets)[0].vars['vsphere_password'],
  String[1] $vsphere_datacenter = get_targets($targets)[0].vars['vsphere_datacenter'],
  Boolean $vsphere_insecure     = get_targets($targets)[0].vars['vsphere_insecure'],
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $lock_check_timeout = 600,
  Integer[0] $lock_retry_interval = 5,
  Boolean    $fail_plan_on_errors = true,
) {

  $services_before_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # placeholder for patching::snapshot_vmware, replace once firewall rules in place/confirmed working
  run_plan('profile::snapshot_placeholder', targets              => $targets,
                                            target_name_property => $target_name_property,
                                            vsphere_host         => $vsphere_host,
                                            vsphere_username     => $vsphere_username,
                                            vsphere_password     => $vsphere_password,
                                            vsphere_datacenter   => $vsphere_datacenter,
                                            vsphere_insecure     => $vsphere_insecure
  )
  #run_plan('patching::snapshot_vmware', targets              => $targets,
  #                                      action               => 'create',
  #                                      target_name_property => $target_name_property,
  #                                      vsphere_host         => $vsphere_host,
  #                                      vsphere_username     => $vsphere_username,
  #                                      vsphere_password     => $vsphere_password,
  #                                      vsphere_datacenter   => $vsphere_datacenter,
  #                                      vsphere_insecure     => $vsphere_insecure
  #)

  run_plan('reboot', targets => $targets, reconnect_timeout => $reconnect_timeout)

  # insert additional delay/sleep before running pe_patch, as pe_patch fact
  # generation runs on boot and can end up locking itself out
  run_plan('profile::pe_patch_lock_check', targets => $targets, lock_check_timeout => $lock_check_timeout)

  $patch_result = run_task('pe_patch::patch_server', $targets, reboot => 'patched')

  $services_after_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # check if any services from before patching are not running
  $service_changes = $services_before_patching.reduce({}) | $memo, $pre_result | {
    $target_name = $pre_result.target().name()
    $post_result = $services_after_patching.find($target_name)

    # repetitive loops as reduce() didn't want to create nested hash
    # service in pre-results but not in post-results
    $pre_but_not_post = $pre_result['service'].filter | $pre_service_name, $pre_service_values | {
      ! $pre_service_name in $post_result['service'].keys()
    }
    # service in post-results but not in pre-results
    $post_but_not_pre = $post_result['service'].filter | $post_service_name, $post_service_values | {
      ! $post_service_name in $pre_result['service'].keys()
    }
    $changed_services = $pre_result['service'].filter | $pre_service_name, $pre_service_values | {
      if $pre_service_name in $post_result['service'].keys() {
        # ensure (running/stopped) is not in the same state as prior to patching
        $pre_result['service'][$pre_service_name]['ensure'] != $post_result['service'][$pre_service_name]['ensure']
      }
    }
    # if any of these are non-empty, add to results (if all are empty this means no changes)
    unless ( $changed_services.empty and $pre_but_not_post.empty and $post_but_not_pre.empty ) {
      $memo + { $target_name => {
                  'changed_status'    => $changed_services,
                  'absent_post_patch' => $pre_but_not_post,
                  'new_post_patch'    => $post_but_not_pre,
                }
              }
    }
  }

  if service_changes.empty {
    return()
  } else {
    return $service_changes
  }
}
