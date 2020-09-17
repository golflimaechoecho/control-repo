plan profile::copy_eventlog_placeholder (
  TargetSpec $targets,
) {
  # assumes only windows targets have been passed (otherwise we keep rechecking facts)
  out::message("Placeholder: (Windows) copy eventlog to C:\Admin\log")
}
