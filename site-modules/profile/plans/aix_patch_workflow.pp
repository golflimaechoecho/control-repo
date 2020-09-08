# aix_patch_workflow
plan profile::aix_patch_workflow (
  TargetSpec $nimserver,
  TargetSpec $nimclients,
) {
  # Check sufficient space before starting
  run_task('profile::aix_check_space', $nimserver)
  run_task('profile::aix_check_space', $nimclients)

  # extract Target names for $nimclients
  $nimclient_names = get_targets($nimclients).map | $n } { $n.name }

  run_plan('profile::aix_patch_node', targets => $nimserver, nimclients => $nimclient_names)
}
