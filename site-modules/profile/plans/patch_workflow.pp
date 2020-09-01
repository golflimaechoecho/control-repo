# extremely simple plan to reboot before patching
plan profile::patch_workflow (
  TargetSpec $targets,
  Integer[0] $reconnect_timeout = 180,
) {
  run_plan('reboot', targets => $targets, reconnect_timeout => $reconnect_timeout)

  return run_task('pe_patch::patch_server', targets => $targets, reboot => 'patched')
}
