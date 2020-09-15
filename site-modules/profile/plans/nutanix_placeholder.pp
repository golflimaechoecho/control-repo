# @placeholder for nutanix snapshot pending further details
plan profile::nutanix_placeholder (
  TargetSpec $controller_vm,
  TargetSpec $targetvm,
  Enum['create', 'delete', 'get', 'list'] $action,
  Optional[Pattern[/[^\"\'\[\]\,\?\* \&\|\;\:]/]] $snapshot_name = undef,
  Boolean $noop = false,
) {
  # placeholder for nutanix
  $_snapshot_name = pick($snapshot_name, '')
  out::message("Placeholder: ${action} nutanix snapshot ${_snapshot_name} using ${controller_vm} for ${targetvm}")
}
