plan profile::rhel_physical_backup_placeholder (
  TargetSpec $targets,
) {
  # note: facts plan fails on AIX, appears this is due to user facts from hardening/os_hardening
  run_plan(facts, targets => $targets, '_catch_errors' => true)

  $redhat_targets = get_targets($targets).filter | $target | {
    $target.facts['os']['family'] == 'RedHat'
  }

  out::message("Placeholder for rhel physical backup")

  # run in noop for now pending testing of task
  run_task('profile::rhel_physical_backup', $redhat_targets, local_backup_path => '/opt', remote_host => 'DCCEBRSMA05', noop => true, '_catch_errors' => true)
}
