# check if pe_patch locked and attempt to wait until no longer locked
# Note: checks for the presence of lockfile only
# requires the reboot::sleep function
#
# @param targets Targets to check
# @param lock_check_timeout How long (in seconds) to attempt to recheck before giving up. Defaults to 600.
# @param lock_retry_interval How long (in seconds) to wait between retries. Defaults to 5.
# @param fail_plan_on_errors Raise an error if any targets do not successfully unlock. Defaults to true.
plan profile::pe_patch_lock_check (
  TargetSpec $targets,
  Integer[0] $lock_check_timeout = 600,
  Integer[0] $lock_retry_interval = 5,
  Boolean    $fail_plan_on_errors = true,
) {

  $target_objects = get_targets($targets)

  # Short-circuit the plan if the TargetSpec given was empty
  if $target_objects.empty { return ResultSet.new([]) }

  # Get current lock status
  $check_lock_results = without_default_logging() || {
    run_task('profile::pe_patch_locked', $target_objects)
  }

  # only care about targets that are locked
  $begin_lock_results = $check_lock_results.filter_set | $res | { $res['pe_patch_locked'] == true }

  $start_time = Timestamp()
  # Wait to unlock in a loop
  ## retrieve latest locked status
  ## Mark finished for targets that are unlocked
  ## If we still have targets check for timeout, sleep if not done.
  $wait_results = without_default_logging() || {
    $lock_check_timeout.reduce({'pending' => $begin_lock_results.targets(), 'ok' => []}) |$memo, $_| {
      if ($memo['pending'].empty() or $memo['timed_out']) {
        break()
      }

      $plural = if $memo['pending'].size() > 1 { 's' }
      out::message("Waiting: ${$memo['pending'].size()} target${plural} locked")
      $current_lock_results = run_task('profile::pe_patch_locked', $memo['pending'], _catch_errors => true)
      # Compare lock results
      $failed_results = $current_lock_results.filter |$current_lock_res| {
        # If this one errored, need to check it again
        if !$current_lock_res.ok() {
          true
        }
        else {
          # If this succeeded, check if it is locked
          $target_name = $current_lock_res.target().name()
          $current_lock_res['pe_patch_locked']
        }
      }
      # $failed_results is an array of results, turn it into a ResultSet so we can
      # extract the targets from it
      $failed_targets = ResultSet($failed_results).targets()
      $ok_targets = $memo['pending'] - $failed_targets
      # Calculate whether or not timeout has been reached
      $elapsed_time_sec = Integer(Timestamp() - $start_time)
      $timed_out = $elapsed_time_sec >= $lock_check_timeout
      if !$failed_targets.empty() and !$timed_out {
        # sleep for a small time before trying again
        reboot::sleep($lock_retry_interval)
        # wait for all targets to be available again
        $remaining_time = $lock_check_timeout - $elapsed_time_sec
        wait_until_available($failed_targets, wait_time => $remaining_time, retry_interval => $lock_retry_interval)
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
    kind => 'bolt/unlock-timeout',
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
