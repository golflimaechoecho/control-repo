#Requires -Version 3.0

# check for presence of pe_patch lock file
# for our purposes if the file exists we assume locked (pe_patch does more detailed checking)
[String]$LockFile = "$($env:programdata)\pe_patch\pe_patch_groups.lock"

if (Test-Path $LockFile) {
  $lockresult = "true"
} else {
  $lockresult = "false"
}
Write-Output "{""pe_patch_locked"": ${lockresult} }"
