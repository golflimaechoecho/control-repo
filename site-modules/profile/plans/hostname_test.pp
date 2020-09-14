# test host output
plan profile::hostname (
  TargetSpec $targets,
) {
  get_targets($targets).each | $target | {
    $target_hostname = $target.host
    out::message("Target ${target} hostname is: ${target_hostname}")
  }
}
