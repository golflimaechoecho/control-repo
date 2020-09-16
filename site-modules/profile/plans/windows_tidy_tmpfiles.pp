# @summary delete *.tmp files recursively
#
# intended to be the equivalent of: del c:\*.tmp /s /q
#
# @param targets Targets to tidy
# @param tidypath Path to tidy (ensure trailing slashes are escaped eg: 'C:\\')
# @param noop Whether to run in noop. Defaults to false (ie: will remove files)
#
plan profile::windows_tidy_tmpfiles (
  TargetSpec $targets,
  Stdlib::Absolutepath $tidypath = 'C:\\',
  Boolean $noop = false,
) {
  without_default_logging() || {
    run_plan(facts, targets => $targets, '_catch_errors' => true)
  }

  # Filter windows targets only
  $windows_targets = get_targets($targets).filter | $target | {
    $target.facts['os']['name'] == 'windows'
  }

  $tidypattern = '*.tmp'

  # check if provided path ends with '\'
  if $tidypath =~ Pattern[/[\\]$/] {
    # tidypath already ends in '\', don't add another one
    $cmdpattern = "${tidypath}${tidypattern}"
  } else {
    # tidypath does not end in '\'
    $cmdpattern = "${tidypath}\\${tidypattern}"
  }

  # below del syntax gives errors as it appears to be running in powershell
  #$command = "del ${cmdpattern} /s /q"

  # Do we want to try Remove-Item with recurse?
  # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7#example-4--delete-files-in-subfolders-recursively
  # see note:
  # > Because the Recurse parameter in Remove-Item has a known issue, the command
  # > in this example uses Get-ChildItem to get the desired files, and then uses
  # > the pipeline operator to pass them to Remove-Item.
  #
  $command = "Get-ChildItem ${tidypath} -Include ${tidypattern} -Recurse | Remove-Item"

  if $noop {
    out::message("Run tmpfile cleanup: ${command}")
  } else {
    return(run_command($command, $windows_targets, '_catch_errors' => true))
  }

  return()
}
