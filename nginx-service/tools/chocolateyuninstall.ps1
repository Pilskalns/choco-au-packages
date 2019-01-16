
Write-Host "Removing nginx-service from services..." -ForegroundColor Red
$ErrorActionPreference = 'SilentlyContinue'
nssm stop nginx-service 2>&1 | Out-Null
nssm remove nginx-service confirm 2>&1 | Out-Null
Uninstall-BinFile -Name "nginx-service"
$ErrorActionPreference = 'Stop'
