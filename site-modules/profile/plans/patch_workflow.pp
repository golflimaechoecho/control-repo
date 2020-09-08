# extremely simple plan to reboot before patching
# @param targets Targets to patch
# @param reconnect_timeout How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 180.
# @param lock_check_timeout How long (in seconds) to attempt to recheck before giving up. Defaults to 600.
# @param lock_retry_interval How long (in seconds) to wait between retries. Defaults to 5.
# @param fail_plan_on_errors Raise an error if any targets do not successfully unlock. Defaults to true.
plan profile::patch_workflow (
  TargetSpec $targets,
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $lock_check_timeout = 600,
  Integer[0] $lock_retry_interval = 5,
  Boolean    $fail_plan_on_errors = true,
) {
) {
  run_plan('reboot', targets => $targets, reconnect_timeout => $reconnect_timeout)

  run_plan('profile::pe_patch_lock_check', targets => $targets, lock_check_timeout => $lock_check_timeout)

  # for windows may need to insert additional delay/sleep before running pe_patch
  # pe_patch fact generation runs on boot; on windows it ends up locking itself out
  return run_task('pe_patch::patch_server', $targets, reboot => 'patched')
}
