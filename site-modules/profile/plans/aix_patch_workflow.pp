# aix_patch_workflow
#
# @param nimserver NIM server to use for patching
# @param nimclients NIM clients to be patched
# @param reconnect_timeout How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 600.
# @param perform_reboot Whether to perform reboot or just print message. Defaults to true.
# @param dry_run Currently unused; could be used to determine whether to actually run. Defaults to false.
#
plan profile::aix_patch_workflow (
  TargetSpec $nimserver,
  TargetSpec $nimclients,
  Integer[0] $reconnect_timeout = 600,
  Boolean    $perform_reboot = true,
  Boolean    $dry_run = false,
  Stdlib::Absolutepath $mksysb_location = '/export/nim/mksysb',
  Stdlib::Absolutepath $spot_location = '/export/nim/spot',
) {

  # Only pass one NIM server, otherwise how will we know which server to use for which clients
  if ( get_targets($nimserver).size != 1 ) {
    fail_plan('Only one NIM server is permitted',
      'bolt/aix_patch_workflow-failed', {
        action     => 'plan/aix_patch_workflow',
        result_set => $nimserver,
    })
  }

  # Collect facts
  # facts plan fails on AIX, appears this is due to user facts from hardening/os_hardening
  #run_plan(facts, targets => $nimserver, '_catch_errors' => true)
  #run_plan(facts, targets => $nimclients, '_catch_errors' => true)

  # Filter AIX targets only
  $aix_nimserver = get_targets($nimserver).filter | $nsrv | {
    # If there is a fact/role to indicate it is a NIM server, could also check here eg:
    #$nsrv.facts['os']['name'] == 'AIX' and $nsrv.trusted['extensions']['pp_role'] == 'nimserver'

    # for now just check it's AIX
    #$nsrv.facts['os']['name'] == 'AIX'
    true
  }

  $aix_nimclients = get_targets($nimclients).filter | $nimclient | {
    #$nimclient.facts['os']['name'] == 'AIX'
    true
  }

  # Check sufficient space before starting
  # This runs on individual clients
  out::message("Placeholder to check space")
  run_task('profile::aix_check_space_placeholder', $aix_nimserver, filesystem => '/', '_catch_errors' => true)
  run_task('profile::aix_check_space_placeholder', $aix_nimclients, filesystem => '/', '_catch_errors' => true)

  # If the NIM server can operate on multiple clients in parallel, the task(s)
  # being called could be written to pass a list of client names instead of
  # iterating over each in turn; then logic below could be updated to reflect this.
  # eg: extract Target names to pass as parameter:
  #$nimclient_names = get_targets($nimclients).map | $n } { $n.name }

  $nimserver_name = get_target($aix_nimserver).name

  # Loop over each client (assumes the NIM server will operate on one client at a time)
  $aix_nimclients.each | $nimclient | {
    # Assumes NIM server can parse client names in same format as TargetSpec (eg: certname/fqdn)
    # eg: could possibly use .host rather than .name depending on NIM requirements
    # https://puppet.com/docs/bolt/latest/bolt_types_reference.html#target
    $nimclient_name = $nimclient.host

    out::message("Placeholder connectivity check on ${nimserver_name} for ${nimclient_name}")
    # Check NIM server can connect to the client (triggered from NIM server, passing client as parameter)
    run_task('profile::aix_nim_connectivity_placeholder', $nimserver, nimclient => $nimclient_name, '_catch_errors' => true)

    out::message("Placeholder mksysb on ${nimserver_name} for ${nimclient_name}")
    # Perform mksysb (triggered from NIM server, passing client as parameter)
    run_task('profile::aix_mksysb_via_nim_placeholder', $nimserver, nimclient => $nimclient_name, mksysb_location => $mksysb_location, spot_location => $spot_location, '_catch_errors' => true)

    out::message("Placeholder patch install on ${nimserver_name} for ${nimclient_name}")
    # install patches (triggered from the NIM server, passing client as parameter)
    run_task('profile::aix_install_patch_via_nim_placeholder', $nimserver, nimclient => $nimclient_name, '_catch_errors' => true)

    out::message("Reboot for ${nimclient_name} - perform_reboot is ${perform_reboot}")
    if $perform_reboot and ( ! $dry_run ) {
      # Reboot the NIM client after patch installation
      run_plan('reboot', targets => $nimclient, reconnect_timeout => $reconnect_timeout, '_catch_errors' => true)
    } else {
      out::message("Skipping reboot for ${nimclient_name} as perform_reboot ${perform_reboot} or dry_run ${dry_run} specified")
    }
  }

  return()
}
