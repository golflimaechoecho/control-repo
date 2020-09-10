# aix_patch_workflow
#
# @param nimserver NIM server to use for patching
# @param nimclients NIM clients to be patched
# @param reconnect_timeout How long (in seconds) to attempt to reconnect after reboot before giving up. Defaults to 600.
#
plan profile::aix_patch_workflow (
  TargetSpec $nimserver,
  TargetSpec $nimclients,
  Integer[0] $reconnect_timeout = 600,
) {

  # Collect facts
  run_plan(facts, targets => $nimserver)
  run_plan(facts, targets => $nimclients)

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
  run_task('profile::aix_check_space_placeholder', $aix_nimserver, filesystem => '/')
  run_task('profile::aix_check_space_placeholder', $aix_nimclients, filesystem => '/')

  # If the NIM server can operate on multiple clients in parallel, the task(s)
  # being called could be written to pass a list of client names instead of
  # iterating over each in turn; then logic below could be updated to reflect this.
  # eg: extract Target names to pass as parameter:
  #$nimclient_names = get_targets($nimclients).map | $n } { $n.name }

  $nimserver_name = $aix_nimserver.name

  # Loop over each client (assumes the NIM server will operate on one client at a time)
  $aix_nimclients.each | $nimclient | {
    # Assumes NIM server can parse client names in same format as TargetSpec (eg: certname/fqdn)
    # eg: could possibly use .host rather than .name depending on NIM requirements
    # https://puppet.com/docs/bolt/latest/bolt_types_reference.html#target
    $nimclient_name = $nimclient.name

    out::message("Placeholder connectivity check on ${nimserver_name} for ${nimclient_name}")
    # Check NIM server can connect to the client (triggered from NIM server, passing client as parameter)
    run_task('profile::aix_nim_connectivity_placeholder', $nimserver, nimclient => $nimclient_name)

    out::message("Placeholder mksysb on ${nimserver_name} for ${nimclient_name}")
    # Perform mksysb (triggered from NIM server, passing client as parameter)
    run_task('profile::aix_mksysb_via_nim_placeholder', $nimserver, nimclient => $nimclient_name)

    out::message("Placeholder patch install on ${nimserver_name} for ${nimclient_name}")
    # install patches (triggered from the NIM server, passing client as parameter)
    run_task('profile::aix_install_patch_via_nim_placeholder', $nimserver, nimclient => $nimclient_name)

    out::message("Reboot for ${nimclient_name}")
    # Reboot the NIM client after patch installation
    run_plan('reboot', targets => $nimclient, reconnect_timeout => $reconnect_timeout)
  }
}
