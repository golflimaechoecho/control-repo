# @summary nutanix snapshots
#
# Initial attempt with details provided to date
#
# @param controller_vm Nutanix CVM to perform snapshot
# @param targetvm VM to snapshot
# @param action Whether to create, delete, get, list snapshot
#   Note: delete and get are theoretical/have had detail provided to date
#   For future, would vm.get be useful to check for orphaned snapshots, or should that be done manually?
#   https://portal.nutanix.com/page/documents/kbs/details?targetId=kA032000000TVH3CAO
# @param snapshot_name Name of snapshot (or snapshot UUID for delete and get)
#   Use Pattern for rudimentary validation. See also: Usable characters in VM snapshot names
#   https://portal.nutanix.com/page/documents/kbs/details?targetId=kA00e000000XdyiCAC
# @param noop Whether to run in noop. Defaults to false.
#
plan profile::snapshot_nutanix (
  TargetSpec $controller_vm,
  TargetSpec $targetvm,
  Enum['create', 'delete', 'get', 'list'] $action,
  Optional[Pattern[/[^\"\'\[\]\,\?\* \&\|\;\:]/]] $snapshot_name = undef,
  Boolean $noop = false,
){
  # Only one CVM target permitted, as we currently don't have a method to
  # determine which CVM to use for which client(s)
  if ( get_targets($controller_vm).size != 1 ) {
    fail_plan('Only one CVM is permitted',
      'bolt/snapshot_nutanix-failed', {
        action     => 'plan/snapshot_nutanix',
        result_set => $controller_vm,
    })
  }

  # get the shortname from the uri - will still be lowercase
  $target_vm_hostname = regsubst(get_targets($targetvm)[0].uri, '^([^.]+).*','\1')

  # Fail if snapshot_name not provided for delete and get
  if $action in ['delete', 'get'] and $snapshot_name == undef {
    fail_plan("snapshot_name is required for ${action}",
      'bolt/snapshot_nutanix-failed', {
        result => 'null',
    })
  }

  # Attempt to set a default snapshot_name for create if one hasn't been specified
  $_snapshot_name = pick($snapshot_name, "${target_vm_hostname}_snapshot")

  case $action {
    'create': {
      $command = "acli vm.snapshot_create ${target_vm_hostname} snapshot_name_list=${_snapshot_name}"
    }
    'delete': {
      $command = "acli snapshot.delete ${snapshot_name}"
    }
    'get': {
      $command = "acli snapshot.get ${snapshot_name}"
    }
    'list': {
      $command = "acli snapshot.list"
    }
    default: {
      out::message("Invalid action specified")
      fail_plan("Invalid action provided: ${action}",
        'bolt/snapshot_nutanix-failed', {
          result => 'null',
      })
    }
  }

  if $noop {
    out::message("Noop specified, would have run: ${command} on ${controller_vm}")
  } else {
    return(run_command($command, $controller_vm, '_catch_errors' => true))
  }

  return()
}
