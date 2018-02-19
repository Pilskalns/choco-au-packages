
$ErrorActionPreference = 'Stop'; # stop on all errors
$version    = $env:chocolateyPackageVersion -replace "-beta.*",""
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$nginxDir   = "$($env:ChocolateyInstall)\lib\nginx\tools\nginx-$($version)"
$installDir = "C:\tools\nginx"

$legacyDir = "C:\ProgramData\nginx\conf.d"


if(-not (Test-Path "$installDir\conf.d\")){
	New-Item -ItemType Directory -Force -Path "$installDir\conf.d\" | Out-Null
}

<#
	Determine if we need to try migrate config files from package version 1.6.2.1 and below
#>
$migratedOldConfig = $false
if ( (Test-Path "$legacyDir\") -eq $True -And (Test-Path "$legacyDir\nginx-service-migrated.dat") -eq $False){
	"Done on version $($env:ChocolateyPackageName) $($env:chocolateyPackageVersion), $(Get-Date)" | out-file "C:\ProgramData\nginx\conf.d\nginx-service-migrated.dat"
	Copy-Item "C:\ProgramData\nginx\conf.d\*" "$installDir\conf.d\" -Recurse -Force -include "*.conf"
	$migratedOldConfig = $true
}

<#
	Copy fresh config files from nginx conf
#>
Copy-Item "$nginxDir\*" $installDir -Recurse -Force -Exclude @("*.exe","html")

if(-not (Test-Path "$installDir\html")){
	New-Item -ItemType Directory -Force -Path "$installDir\html\" | Out-Null
	Copy-Item "$nginxDir\html\*" "$installDir\html" -Recurse -Force
}

Copy-Item "$toolsDir\conf\nginx.conf" "$installDir\conf" -Force


$confdInfo = Get-ChildItem "$installDir\conf.d" | Measure-Object
if($confdInfo.count -eq 0){
	Copy-Item "$toolsDir\conf.d\*" "$installDir\conf.d\" -Recurse -Force
}

<#
	Actual service installation
#>
$ErrorActionPreference = 'SilentlyContinue'

net stop nginx 2>&1 | Out-Null # Wishfull thinking
sc delete nginx 2>&1 | Out-Null # Wishfull thinking

nssm stop nginx 2>&1 | Out-Null
nssm remove nginx confirm 2>&1 | Out-Null
nssm install nginx "$nginxDir\nginx.exe" 2>&1 | Out-Null
nssm set nginx Description "Awsome HTTP web server, service managed by NSSM" 2>&1 | Out-Null
nssm set nginx AppDirectory  "$installDir" 2>&1 | Out-Null
nssm set nginx AppNoConsole 1 2>&1 | Out-Null # Mentioned on top off http://nssm.cc/download
nssm set nginx AppParameters "-p """"$installDir""""" 2>&1 | Out-Null
nssm set nginx AppStopMethodSkip 7 2>&1 | Out-Null
nssm start nginx 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'

<#
	Throw some barebones info for user
#>
Write-Host ""
if($migratedOldConfig){
	Write-Host "Migrated config from previous installation in ""$legacyDir\"","  -ForegroundColor Yellow
	Write-Host "remove completely or leave this dir as is" -ForegroundColor Yellow
	Write-Host "If you just remove '{Old conf.d}\nginx-service-migrated.dat' then," -ForegroundColor Yellow
	Write-Host "on next installation time, files will be imported again" -ForegroundColor Yellow
	Write-Host ""
}

Write-Host @"
Config file(s) location "$installDir\conf.d"

Nginx now can be started and stopped as regular Windows service or trough NSSM command interface
Type one of those commands in CMD or PowerShell for nginx-service control:

"@  -ForegroundColor Green
Write-Host "To start service:" -ForegroundColor Green
Write-Host "    net start nginx" -ForegroundColor Yellow
Write-Host "    or" -ForegroundColor Green
Write-Host "    nssm start nginx" -ForegroundColor Yellow

Write-Host "To stop service:" -ForegroundColor Green
Write-Host "    net stop nginx" -ForegroundColor Yellow
Write-Host "    or" -ForegroundColor Green
Write-Host "    nssm stop nginx" -ForegroundColor Yellow

Write-Host "To restart service do both:" -ForegroundColor Green
Write-Host "    net stop nginx" -ForegroundColor Yellow
Write-Host "    net start nginx" -ForegroundColor Yellow
Write-Host "    or" -ForegroundColor Green
Write-Host "    nssm stop nginx" -ForegroundColor Yellow
Write-Host "    nssm start nginx" -ForegroundColor Yellow
