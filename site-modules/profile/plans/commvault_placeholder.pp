# @summary placeholder for commvault until functionality determined/tested
#
# @param [TargetSpec] targets
#   Targets to query backup for
#
# @param Optional[String[1]] commvault_api_server
#   Hostname/FQDN of the CommVault API server
#
# @param Optional[Integer[0, 65535]] commvault_api_port
#   Port to use to connect to CommVault API server
#
# @param api_user
#   Username to access CommVault API
#
# @param api_password
#   password to access CommVault API
#
plan profile::commvault_placeholder (
  TargetSpec $targets,
  Optional[String[1]] $commvault_api_server = 'dccebrssq01.w2k.bnm.gov.my',
  Optional[Integer[0, 65535]] $commvault_api_port = 81,
  String[1] $api_user = 'puppetadm',
  String[1] $api_password = 'Qm5tQDIwMjA=',
) {
  # placeholder for commvault
  out::message("Placeholder: Run commvault backup")

  # this plan is slightly different as the API calls will be made from the PE server not the targets
  $pe_server = "dccvmscmmaster01.w2k.bnm.gov.my"

  $baseurl = "http://${commvault_api_server}:${commvault_api_port}/SearchSvc/CVWebService.svc"
  $content_type = '"Content-Type: application/xml"'
  $accept = '"Accept: application/json"'

  $login_data = "'<DM2ContentIndexing_CheckCredentialReq mode=\"Webconsole\" username=\"${api_user}\" password=\"${api_password}\" />'"

  $login_command = "curl -X POST ${baseurl}/Login -H ${content_type} -H ${accept} -d ${login_data}"
  out::message($login_command)

  # target is PE server
  $login_results = run_command($login_command, $pe_server, '_catch_errors' => true)

  $login_results.each | $login_result | {
    out::message("login result is ${login_result}")
  }

  # assume we can get $authtoken from above result
  # authtoken expires after 30 minutes (ie: we're assuming we can complete in that time)
  $token = 'QSDK placeholder'
  $authtoken = "Authtoken: ${token}"

  $targets.get_targets().each | $target | {
    $target_name = $target.name

    # does commvault need the shortname?

    $client_id_command = "curl -X GET ${baseurl}/GetId?clientName=${target_name} -H ${accept} -H ${authtoken}"
    out::message($client_id_command)

    #$client_id_results = run_command($client_id_command, $pe_server, '_catch_errors' => true)

    #$client_id = $client_id_results[0].blah
    $client_id = '1234'

    $job_id_command = "curl -X GET ${baseurl}/Job?clientId=${client_id} -H ${accept} -H ${authtoken}"
    out::message($job_id_command)
    #$job_id_results = run_command($job_id_command, $pe_server, '_catch_errors' => true)
  }

  return()
}
