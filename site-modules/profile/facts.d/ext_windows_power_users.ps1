#Requires -Version 3.0
$query = {$Ms = net localgroup 'Power Users' | where {$_ -AND $_ -notmatch 'command completed successfully'} | select -skip 4 ;foreach($m in $Ms){$users += $M+' , '}; return $Users}
$result = & $query
Write-Output "{""ext_windows_power_users"": ${result} }"
