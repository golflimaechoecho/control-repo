#Requires -Version 3.0
$Ms = (net localgroup 'Power Users' | where {$_ -AND $_ -notmatch 'command completed successfully'} | select -skip 4)
$result = foreach($m in $Ms){$users += $M+' , '}; return $Users
Write-Output "{""ext_windows_power_users"": ${result} }"
