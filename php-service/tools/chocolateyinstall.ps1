
$ErrorActionPreference = 'Stop'; # stop on all errors
$version    = $env:chocolateyPackageVersion -replace "-beta.*",""
$installDir = "$($env:ChocolateyToolsLocation)\php{0}" -f ($version -replace '\.').Substring(0,2)

<#
	Actual service installation
#>
$ErrorActionPreference = 'SilentlyContinue'

net stop php 2>&1 | Out-Null # Wishfull thinking
sc delete php 2>&1 | Out-Null # Wishfull thinking

nssm stop php 2>&1 | Out-Null
nssm remove php confirm 2>&1 | Out-Null
nssm install php "$($installDir)\php-cgi.exe" 2>&1 | Out-Null
nssm set php Description "PHP, service managed by NSSM" 2>&1 | Out-Null
nssm set php AppDirectory  "$installDir" 2>&1 | Out-Null
nssm set php AppParameters "-b """"127.0.0.1:9000""""" 2>&1 | Out-Null
# nssm set php AppNoConsole 1 2>&1 | Out-Null # Mentioned on top off http://nssm.cc/download
# nssm set php AppStopMethodSkip 7 2>&1 | Out-Null
nssm start php 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'

<#
	Throw some barebones info for user
#>

Write-Host @"
Config file "$installDir\php.ini"

PHP now can be started and stopped as regular Windows service or through NSSM command interface
Type one of those commands in CMD or PowerShell for php-service control:

"@  -ForegroundColor Green
Write-Host "To start service:" -ForegroundColor Green
Write-Host "    net start php" -ForegroundColor Yellow
Write-Host "    or" -ForegroundColor Green
Write-Host "    nssm start php" -ForegroundColor Yellow

Write-Host "To stop service:" -ForegroundColor Green
Write-Host "    net stop php" -ForegroundColor Yellow
Write-Host "    or" -ForegroundColor Green
Write-Host "    nssm stop php" -ForegroundColor Yellow

Write-Host "To restart service do both:" -ForegroundColor Green
Write-Host "    net stop php" -ForegroundColor Yellow
Write-Host "    net start php" -ForegroundColor Yellow
Write-Host "    or" -ForegroundColor Green
Write-Host "    nssm stop php" -ForegroundColor Yellow
Write-Host "    nssm start php" -ForegroundColor Yellow
