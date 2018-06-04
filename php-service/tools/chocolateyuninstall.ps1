$ErrorActionPreference = 'SilentlyContinue'
nssm stop php 2>&1 | Out-Null
nssm remove php confirm 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'
