#Requires -Version 3.0
$result = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
Write-Output "{""windows_product_name"": ${result} }"
