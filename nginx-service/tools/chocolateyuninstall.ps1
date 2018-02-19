
$ErrorActionPreference = 'SilentlyContinue'
nssm stop nginx 2>&1 | Out-Null
nssm remove nginx confirm 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'