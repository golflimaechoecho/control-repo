# plan to check service ... checking
#
# @param targets Targets to patch
# @param reconnect_timeout How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 180.
# @param lock_check_timeout How long (in seconds) to attempt to recheck before giving up. Defaults to 600.
# @param lock_retry_interval How long (in seconds) to wait between retries. Defaults to 5.
# @param fail_plan_on_errors Raise an error if any targets do not successfully unlock. Defaults to true.
#
plan profile::service_check (
  TargetSpec $targets,
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $lock_check_timeout = 600,
  Integer[0] $lock_retry_interval = 5,
  Boolean    $fail_plan_on_errors = true,
) {

  $services_before_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # stop puppet and SplunkForwarder as example
  run_task('service', $targets, name => 'puppet', action => 'stop')
  run_task('service', $targets, name => 'SplunkForwarder', action => 'stop')

  $services_after_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # check if any services from before patching are not running
  # this doesn't check for any new services (ie: that didn't exist prior to patching)
  $changed_services = $services_before_patching.reduce({}) | $memo, $pre_result | {
    $target_name = $pre_result.target().name()
    $post_result = $services_after_patching.find($target_name)
    $pre_result['service'].keys.each | $pre_service_name | {
      if $pre_service_name in $post_result['service'].keys() {
        if $pre_result['service'][$pre_service_name]['ensure'] != $post_result['service'][$pre_service_name]['ensure'] {
          # ensure (running/stopped) is not in the same state as prior to patching
          out::message("${target_name}: ${pre_service_name} state changed, now ${post_result['service'][$pre_service_name]['ensure']}")
          $memo + { $target_name => { $pre_service_name => "state changed, now ${post_result['service'][$pre_service_name]['ensure']}" } }
        }
      } else {
        # service missing from post_result
        out::message("${target_name} ${pre_service_name} no longer present")
        $memo + { $target_name => { $pre_service_name => "no longer present" } }
      }
    }
  }

  # start these again
  run_task('service', $targets, name => 'puppet', action => 'start')
  run_task('service', $targets, name => 'SplunkForwarder', action => 'start')

  return $changed_services
}
