#Requires -Version 3.0
$users = @{'windows_admin_users_hash' = @()}
foreach ($line in (Get-LocalGroupMember 'Administrators'|Select-Object Name))
{
  $hold = $line -match '\\(?<user>.+)\}'
  $users['windows_admin_users_hash'] += $Matches.user
}
# ensure result quoted to return whole string (otherwise truncates after first ',')
Write-Output (ConvertTo-Json -Compress $users)
