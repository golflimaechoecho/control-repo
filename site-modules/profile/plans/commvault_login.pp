# @summary commvault login to generate API authentication token
#
# Note token expires after 30 minutes
#
# requires parsejson() from puppetlabs/stdlib to parse the json returned by API
#
# @param [TargetSpec] target
#   Target to run the login from (at the time of writing this is the PE server)
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
# @param Boolean dry_run
#   Whether this is a dry_run. Defaults to false.
#
plan profile::commvault_login (
  TargetSpec $targets,
  String[1] $api_initiator = "dccvmscmmaster01.w2k.bnm.gov.my",
  Optional[String[1]] $commvault_api_server = 'dccebrssq01.w2k.bnm.gov.my',
  Optional[Integer[0, 65535]] $commvault_api_port = 81,
  String[1] $api_user = 'puppetadm',
  String[1] $api_password = 'Qm5tQDIwMjA=',
  Boolean $dry_run = false,
) {
  # placeholder for commvault
  out::message("Placeholder: Run commvault backup")

  $baseurl = "http://${commvault_api_server}:${commvault_api_port}/SearchSvc/CVWebService.svc"
  $content_type = '"Content-Type: application/xml"'
  $accept = '"Accept: application/json"'
  $curl_cmd = "curl -S" # show errors, hide progress bar

  $login_data = "'<DM2ContentIndexing_CheckCredentialReq mode=\"Webconsole\" username=\"${api_user}\" password=\"${api_password}\" />'"

  $login_command = "${curl_cmd} -X POST ${baseurl}/Login -H ${content_type} -H ${accept} -d ${login_data}"
  out::message($login_command)

  # target is PE server
  #return(run_command($login_command, $api_initiator, '_catch_errors' => true))
  return(run_command('cat /var/tmp/stdout.txt', $api_initiator, '_catch_errors' => true))
}
