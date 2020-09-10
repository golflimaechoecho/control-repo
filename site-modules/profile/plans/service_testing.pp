# plan to check service ... checking
#
# @param targets Targets to patch
# @param reconnect_timeout How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 180.
# @param lock_check_timeout How long (in seconds) to attempt to recheck before giving up. Defaults to 600.
# @param lock_retry_interval How long (in seconds) to wait between retries. Defaults to 5.
# @param fail_plan_on_errors Raise an error if any targets do not successfully unlock. Defaults to true.
#
plan profile::service_testing (
  TargetSpec $targets,
  Array[String] $example_services = ['puppet'],
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $lock_check_timeout = 600,
  Integer[0] $lock_retry_interval = 5,
  Boolean    $fail_plan_on_errors = true,
) {

  $services_before_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # stop services as an example
  $example_services.each | $service_name | {
    run_task('service', $targets, name => $service_name, action => 'stop')
  }

  $services_after_patching = without_default_logging() || {
    run_task('profile::check_services', $targets)
  }

  # check if any services from before patching are not running
  # this doesn't check for any new services (ie: that didn't exist prior to patching)
  #  $changed_results = $services_before_patching.reduce({}) | $memo, $pre_result | {
  #    $target_name = $pre_result.target().name()
  #    $post_result = $services_after_patching.find($target_name)
  #
  #    # filter hash for services that have changed
  #    $changed_services = $pre_result['service'].filter | $pre_service_name, $pre_service_values | {
  #      if $pre_service_name in $post_result['service'].keys() {
  #        # ensure (running/stopped) is not in the same state as prior to patching
  #        $pre_result['service'][$pre_service_name]['ensure'] != $post_result['service'][$pre_service_name]['ensure']
  #      } else {
  #        true
  #      }
  #    }
  #
  #    $change_hash = $changed_services.reduce({}) | $svc_memo, $svc | {
  #      $pre_service_name = $svc[0]
  #      if $pre_service_name in $post_result['service'].keys() {
  #        $svc_memo + { $pre_service_name => "state changed, now $post_result['service'][$pre_service_name]['ensure']" }
  #        out::message("${target_name} ${pre_service_name} state changed, now ${post_result['service'][$pre_service_name]['ensure']}")
  #      } else {
  #        $svc_memo + { $pre_service_name => 'no longer present' }
  #        out::message("${target_name} ${pre_service_name} no longer present")
  #      }
  #    }
  #    $memo + { $target_name => $change_hash }
  #  }
  #

  # start example services again
  $example_services.each | $service_name | {
    run_task('service', $targets, name => $service_name, action => 'stop')
  }

  #return $changed_results
}
