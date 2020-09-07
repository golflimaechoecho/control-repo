# check if pe_patch locked and attempt to wait until no longer locked
# requires the reboot::sleep function
#
# @param targets Targets to check
# @param recheck_timeout How long (in seconds) to attempt to recheck before giving up. Defaults to 600.
# @param retry_interval How long (in seconds) to wait between retries. Defaults to 1.
# @param fail_plan_on_errors Raise an error if any targets do not successfully unlock. Defaults to true.
plan profile::pe_patch_lock_check (
  TargetSpec $targets,
  Integer[0] $recheck_timeout = 600,
  Integer[0] $retry_interval = 1,
  Boolean    $fail_plan_on_errors = true,
) {

  $target_objects = get_targets($targets)

  # Short-circuit the plan if the TargetSpec given was empty
  if $target_objects.empty { return ResultSet.new([]) }

  # Get current lock status
  $begin_check_results = without_default_logging() || {
    run_task('profile::pe_patch_locked', $targets_objects)
  }

  # Wait long enough for all targets to trigger reboot, plus disconnect_wait to allow for shutdown time.
  $timeouts = $reboot_result.map |$result| { $result['timeout'] }
  $wait = max($timeouts)
  reboot::sleep($wait+$disconnect_wait)

  $start_time = Timestamp()
  # Wait for reboot in a loop
  ## retrieve latest locked status
  ## Mark finished for targets that are unlocked
  ## If we still have targets check for timeout, sleep if not done.
  $wait_results = without_default_logging() || {
    $reconnect_timeout.reduce({'pending' => $target_objects, 'ok' => []}) |$memo, $_| {
      if ($memo['pending'].empty() or $memo['timed_out']) {
        break()
      }

      $plural = if $memo['pending'].size() > 1 { 's' }
      out::message("Waiting: ${$memo['pending'].size()} target${plural} locked")
      $current_boot_time_results = run_task('reboot::last_boot_time', $memo['pending'], _catch_errors => true)
      # Compare boot times
      $failed_results = $current_boot_time_results.filter |$current_boot_time_res| {
        # If this one errored, need to check it again
        if !$current_boot_time_res.ok() {
          true
        }
        else {
          # If this succeeded, then we have a boot time, compare it against the begin_boot_time
          $target_name = $current_boot_time_res.target().name()
          $begin_boot_time_res = $begin_boot_time_results.find($target_name)
          # If the boot times are the same, then we need to check it again
          $current_boot_time_res.value() == $begin_boot_time_res.value()
        }
      }
      # $failed_results is an array of results, turn it into a ResultSet so we can
      # extract the targets from it
      $failed_targets = ResultSet($failed_results).targets()
      $ok_targets = $memo['pending'] - $failed_targets
      # Calculate whether or not timeout has been reached
      $elapsed_time_sec = Integer(Timestamp() - $start_time)
      $timed_out = $elapsed_time_sec >= $reconnect_timeout
      if !$failed_targets.empty() and !$timed_out {
        # sleep for a small time before trying again
        reboot::sleep($retry_interval)
        # wait for all targets to be available again
        $remaining_time = $reconnect_timeout - $elapsed_time_sec
        wait_until_available($failed_targets, wait_time => $remaining_time, retry_interval => $retry_interval)
      }
      # Build and return the memo for this iteration
      ({
        'pending'   => $failed_targets,
        'ok'        => $memo['ok'] + $ok_targets,
        'timed_out' => $timed_out,
      })
    }
  }
  $err = {
    msg  => 'Target failed to unlock before wait timeout.',
    kind => 'bolt/reboot-timeout',
  }
  $error_set = $wait_results['pending'].map |$target| {
    Result.new($target, {
      _output => 'failed to unlock',
      _error  => $err,
    })
  }
  $ok_set = $wait_results['ok'].map |$target| {
    Result.new($target, {
      _output => 'unlocked',
    })
  }
  $result_set = ResultSet.new($ok_set + $error_set)
  if ($fail_plan_on_errors and !$result_set.ok) {
    fail_plan('One or more targets failed to unlock within the allowed wait time',
      'bolt/pe_patch_lock_check-failed', {
        action         => 'plan/pe_patch_lock_check',
        result_set     => $result_set,
        failed_targets => $result_set.error_set.targets, # legacy / deprecated
    })
  }
  else {
    return($result_set)
  }
}
