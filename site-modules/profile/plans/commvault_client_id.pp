# @summary get commvault client ID
#
# Note token expires after 30 minutes
#
# requires parsejson() from puppetlabs/stdlib to parse the json returned by API
#
# @param [TargetSpec] target
#   Target to run the login from (at the time of writing this is the PE server)
#
# @param String[1] commvault_client_name
#   commvault client name to query
#
# @param [Optional[String[1]]] commvault_api_server
#   Hostname/FQDN of the CommVault API server
#
# @param [Optional[Integer[0, 65535]]] commvault_api_port
#   Port to use to connect to CommVault API server
#
# @param [String[1]] api_user
#   Username to access CommVault API
#
# @param [String[1]] api_password
#   password to access CommVault API
#
# @param String[1] api_initiator
#   Default to the certname of the PE server, parameterise to allow testing
#   (the API calls to commvault are made from the PE server, not the targets themselves)
#
# @param Optional[String[1]] token
#   An existing token (if available). Defaults to undef (ie: will generate new token)
#
# @param Boolean dry_run
#   Whether this is a dry_run. Defaults to false.
#
plan profile::commvault_client_id (
  TargetSpec $targets,
  String[1] $commvault_client_name,
  String[1] $api_initiator = "dccvmscmmaster01.w2k.bnm.gov.my",
  Optional[String[1]] $commvault_api_server = 'dccebrssq01.w2k.bnm.gov.my',
  Optional[Integer[0, 65535]] $commvault_api_port = 81,
  String[1] $api_user = 'puppetadm',
  String[1] $api_password = 'Qm5tQDIwMjA=',
  Optional[String[1]] $token = undef,
  Boolean $dry_run = false,
) {
  $baseurl = "http://${commvault_api_server}:${commvault_api_port}/SearchSvc/CVWebService.svc"
  $content_type = '"Content-Type: application/xml"'
  $accept = '"Accept: application/json"'
  $curl_cmd = "curl -S" # show errors, hide progress bar

  if $token == undef {
    out::message("No token provided, generating new")
    $login_results = run_plan('profile::commvault_login', $api_initiator, '_catch_errors' => true)

    # note authtoken expires after 30 minutes (ie: below assumes we can complete in that time)
    # API returns JSON string to stdout
    # get the result data, convert the stdout field with parsejson() to get the token
    # use .first as there should only be one result/single target
    $login_result_data = $login_results.first.to_data
    $login_result_stdout = parsejson($login_result_data['value']['stdout'])
    $newtoken = $login_result_stdout['token']
    $authtoken = "\"Authtoken: ${newtoken}\""
  } else {
    out::message("Using provided token: ${token}")
    $authtoken = "\"Authtoken: ${token}\""
  }

  $client_id_command = "${curl_cmd} -X GET ${baseurl}/GetId?clientName=${commvault_client_name} -H ${accept} -H ${authtoken}"
  out::message($client_id_command)

  # target is PE server
  #return(run_command($client_id_command, $api_initiator, '_catch_errors' => true))
  return(run_command('cat /var/tmp/clientid.out', $api_initiator, '_catch_errors' => true))
}
