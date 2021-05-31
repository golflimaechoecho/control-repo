#Requires -Version 3.0
$users = @{'windows_power_users_hash' = @()}
foreach ($line in (Get-LocalGroupMember 'Power Users'|Select-Object Name))
{
  $hold = $line -match '\\(?<user>.+)\}'
  $users['windows_power_users_hash'] += $Matches.user
}
# ensure result quoted to return whole string (otherwise truncates after first ',')
Write-Output (ConvertTo-Json -Compress $users)
