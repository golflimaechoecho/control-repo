#Requires -Version 3.0
function GetWUServer {
  # powershell 5+ could use Get-ItemPropertyValue, left as Get-ItemProperty for older versions
  try {
    (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate").WUServer
  }
  catch {
    (Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate").WUServer
  }
  catch {
    "Unable to find WUServer"
  }
}
$result = GetWUServer
Write-Output "{""ext_winupdateserver"": ${result} }"
