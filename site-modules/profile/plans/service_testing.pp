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

  # start example services again
  $example_services.each | $service_name | {
    run_task('service', $targets, name => $service_name, action => 'start')
  }

  if service_changes.empty {
    return()
  } else {
    return $service_changes
  }
}
