# placeholder for aix_patch_workflow
plan profile::aix_nimserver_space (
  TargetSpec $targets,
) {
  out::message('Check NIM server has sufficient space eg: use run_task to run a script to check df -k output')
}
