# $au_Push      = $false # DURING DEBUGGING

. .\update.commons.ps1

("mainline", "stable") | % {
# ("stable") | % {
    
    $type = $_
    Copy-Item "nginx-service.nuspec.$type" "nginx-service.nuspec" -Force | out-null
    
    try {
        Update-Package -ChecksumFor none -NoCheckChocoVersion
        # Update-Package -ChecksumFor none
    } catch {
        $ignore = 'Unable to connect to the remote server'
        if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
    }
    
    Copy-Item "nginx-service.nuspec" "nginx-service.nuspec.$type" -Force | out-null

}
