# extremely simple plan to reboot before patching
plan profile::patch_workflow (
  TargetSpec $targets,
  Integer[0] $reconnect_timeout = 180,
) {
  run_plan('reboot', targets => $targets, reconnect_timeout => $reconnect_timeout)

  # for windows may need to insert additional delay/sleep before running pe_patch
  # pe_patch fact generation runs on boot; on windows it ends up locking itself out
  return run_task('pe_patch::patch_server', $targets, reboot => 'patched')
}
