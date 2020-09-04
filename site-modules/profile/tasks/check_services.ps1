#Requires -Version 3.0
$puppetCmd = Join-Path $env:ProgramFiles -ChildPath "Puppet Labs\Puppet\bin\puppet.bat"
& $puppetCmd resource service
