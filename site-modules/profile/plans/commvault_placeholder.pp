# @summary placeholder for commvault until functionality determined/tested
#
# requires parsejson() from puppetlabs/stdlib to parse the json returned by API
#
# @param [TargetSpec] targets
#   Targets to query backup for
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
plan profile::commvault_placeholder (
  TargetSpec $targets,
  String[1] $api_initiator = "dccvmscmmaster01.w2k.bnm.gov.my",
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

  $login_command = "${curl_cmd} -X POST ${baseurl}/Login -H ${content_type} -H ${accept} -d ${login_data}"
  out::message($login_command)

  # target is PE server
  #$login_results = run_command($login_command, $api_initiator, '_catch_errors' => true)
  $login_results = run_command('cat /var/tmp/stdout.txt', $api_initiator, '_catch_errors' => true)

  # note authtoken expires after 30 minutes (ie: below assumes we can complete in that time)
  # API returns JSON string to stdout
  # get the result data, convert the stdout field with parsejson() to get the token
  # use .first as there should only be one result/single target
  $login_result_data = $login_results.first.to_data
  $login_result_stdout = parsejson($login_result_data['value']['stdout'])
  $token = $login_result_stdout['token']
  $authtoken = "\"Authtoken: ${token}\""

  $targets.get_targets().each | $target | {
    $target_name = $target.name

    # does commvault need the shortname? yes
    # plus physicals are prefixed with '3' eg: '3dccappfunction'
    $target_shortname = regsubst($target_name, '^([^.]+).*','\1')

    $client_id_command = "${curl_cmd} -X GET ${baseurl}/GetId?clientName=${target_shortname} -H ${accept} -H ${authtoken}"
    out::message($client_id_command)

    #$client_id_results = run_command($client_id_command, $api_initiator, '_catch_errors' => true)
    $client_id_results = run_command('cat /var/tmp/clientid.out', $api_initiator, '_catch_errors' => true)
    $client_id_result_data = $client_id_results.first.to_data
    $client_id_result_stdout = parsejson($client_id_result_data['value']['stdout'])
    $client_id = $client_id_result_stdout['clientId']
    out::message("client id is ${client_id}")

    $job_command = "${curl_cmd} -X GET ${baseurl}/Job?clientId=${client_id} -H ${accept} -H ${authtoken}"
    out::message($job_command)
    #$job_results = run_command($job_command, $api_initiator, '_catch_errors' => true)
    $job_results = run_command('cat /var/tmp/commvault_getjoblist.json', $api_initiator, '_catch_errors' => true)

    # native output is jobs as array of hashes?
    # { jobs => [ { jobSummary => {}, jobSummary => {}, [...] } ]

    $job_result_data = $job_results.first.to_data
    $job_result_stdout = parsejson($job_result_data['value']['stdout'])
    $job_list = $job_result_stdout['jobs'] # array of hashes

    # check for lastUpdateTime within 24h
    # jobEndTime is also present but it's not listed as a response parameter
    # https://documentation.commvault.com/commvault/v11/article?p=47608.htm
    # timenow = seconds since epoch, cast as integer
    $timenow = Integer.new(Timestamp.new.strftime('%s'))
    out::message("Timestamp now is ${timenow}")
    $acceptable_time = 86400 # 24 hours

    $within_acceptable_time = $job_list.filter | $jobsummaryhash | {
      $last_update_time = $jobsummaryhash['jobSummary']['lastUpdateTime']
      out::message("last update time is $last_update_time")
      # this assumes last_update_time is returned as an Integer; if not cast similar to $timenow
      # filter (return true) if (now - backup) < acceptable time
      ($timenow - $last_update_time) < $acceptable_time
    }

    if $within_acceptable_time.empty {
      out::message("WARNING: No backups within last ${acceptable_time} seconds")
    } else {
      out::message("Recent backups found, continue")
    }

    $subclient_id_command = "${curl_cmd} -X GET ${baseurl}/Subclient?clientId=${client_id} -H ${accept} -H ${authtoken}"
    out::message($subclient_id_command)

    #$subclient_id_results = run_command($subclient_id_command, $api_initiator, '_catch_errors' => true)
    $subclient_id_results = run_command('cat /var/tmp/subclient.json', $api_initiator, '_catch_errors' => true)

    # (look for the subclient id of "appName":"File System" "appName":"File System","backupsetName":"defaultBackupSet","subclientName":"default")

    $subclient_id_result_data = $subclient_id_results.first.to_data
    $subclient_id_result_stdout = parsejson($subclient_id_result_data['value']['stdout'])
    $subclient_id_list = $subclient_id_result_stdout['subClientProperties'] # array of hashes

    # find subclient with appName 'File System'
    $fs_subclients = $subclient_id_list.filter | $subclienthash | {
      $subclienthash['subClientEntity']['appName'] == 'File System'
    }

    if $fs_subclients.empty {
      out::message("WARNING: could not find subclient id to perform backup")
    } else {
      $subclient_id = $fs_subclients['0']['subClientEntity']['subclientId']
      out::message("subclient id is ${subclient_id}")
    }

    $inititate_backup_command = "${curl_cmd} -X POST ${baseurl}/Subclient/${subclient_id}/action/backup -H ${content_type} -H ${accept} -H ${authtoken}"
    out::message($initiate_backup_command)
  }

  return()
}
