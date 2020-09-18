#Requires -Version 3.0
# example of external fact
# performs the same function as custom fact installed_kb_hotfixes

$result = Get-HotFix | Select-Object HotFixID, Description, InstalledBy, InstalledOn| ConvertTo-Json -Compress
Write-Output "{""installedkb_external"": ${result} }"
