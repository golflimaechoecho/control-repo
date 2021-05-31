#Requires -Version 3.0
$result = & {foreach ($m in (net localgroup administrators | where {$_ -AND $_ -notmatch 'command completed successfully'} |select -skip 4)) {$users += $m+' , '}; return $users}
# ensure result quoted to return whole string (otherwise truncates after first ',')
Write-Output "{""windows_admin_users_reorder"": ""${result}"" }"
