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
# @param String[1] pe_server
#   the API calls to commvault are made from the PE server not the targets themselves
#   Default to the certname of the PE server, parameterising to allow testing
#
plan profile::commvault_placeholder (
  TargetSpec $targets,
  String[1] $pe_server = "dccvmscmmaster01.w2k.bnm.gov.my",
  Optional[String[1]] $commvault_api_server = 'dccebrssq01.w2k.bnm.gov.my',
  Optional[Integer[0, 65535]] $commvault_api_port = 81,
  String[1] $api_user = 'puppetadm',
  String[1] $api_password = 'Qm5tQDIwMjA=',
) {
  # placeholder for commvault
  out::message("Placeholder: Run commvault backup")


  $baseurl = "http://${commvault_api_server}:${commvault_api_port}/SearchSvc/CVWebService.svc"
  $content_type = '"Content-Type: application/xml"'
  $accept = '"Accept: application/json"'
  $curl_cmd = "curl -S" # show errors, hide progress bar

  $login_data = "'<DM2ContentIndexing_CheckCredentialReq mode=\"Webconsole\" username=\"${api_user}\" password=\"${api_password}\" />'"

  $login_command = "curl -X POST ${baseurl}/Login -H ${content_type} -H ${accept} -d ${login_data}"
  out::message($login_command)

  # target is PE server
  #$login_results = run_command($login_command, $pe_server, '_catch_errors' => true)
  $login_results = run_command('cat /var/tmp/stdout.txt', $pe_server, '_catch_errors' => true)

  # there should only be one result; get token field
  # note authtoken expires after 30 minutes (ie: we're assuming we can complete in that time)
  $login_result = $login_results.find($pe_server)
  out::message($login_result)
  $token = $login_result['value']['stdout']['token']
  $authtoken = "\"Authtoken: ${token}\""
  out::message("authtoken is ${authtoken}")

  $targets.get_targets().each | $target | {
    $target_name = $target.name

    # does commvault need the shortname? yes. and physicals are prefixed with '3' eg: '3dcchostname'

    $client_id_command = "curl -X GET ${baseurl}/GetId?clientName=${target_name} -H ${accept} -H ${authtoken}"
    out::message($client_id_command)

    #$client_id_results = run_command($client_id_command, $pe_server, '_catch_errors' => true)

    $client_id = $client_id_results[0]['blah']
    out::message($client_id)

    $job_id_command = "curl -X GET ${baseurl}/Job?clientId=${client_id} -H ${accept} -H ${authtoken}"
    out::message($job_id_command)
    #$job_id_results = run_command($job_id_command, $pe_server, '_catch_errors' => true)
    # native output is jobs as array of hashes?
    # { jobs => [ { jobSummary => {}, jobSummary => {}, [...] } ]

    $subclient_command = "curl -X GET ${baseurl}/Subclient?clientId=${client_id} -H ${accept} -H ${authtoken}"

    # (look for the subclient id of "appName":"File System" "appName":"File System","backupsetName":"defaultBackupSet","subclientName":"default")

    #$subclient_id = $subclient_command_results[0].blah

    $inititate_backup_command = "curl -X POST ${baseurl}/Subclient/${subclient_id}/action/backup -H ${content_type} -H ${accept} -H ${authtoken}"
  }

  return()
}
