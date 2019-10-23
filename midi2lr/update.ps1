$releasesURL = 'https://api.github.com/repos/rsjaffe/MIDI2LR/releases/latest'

function global:au_GetLatest {
    
    $release = Invoke-RestMethod $releasesURL -UseBasicParsing -Headers @{'Accept' = 'application/vnd.github+json, application/json';}
    $url = ''
    $count = 0;
    $versionregex = "midi2lr-([0-9\.])*?-windows-installer.exe"
    $release.assets | % {
        if($_.name -match $versionregex){
            $url = $_.browser_download_url
            $count++
        }
    }
    if($count -ne 1){
        return @{version = "0.0.0"; url = ""}
    }
	@{
		Version = $release.tag_name -replace "v",""
        url 	= $url
        notes   = $release.body
        Year	= get-date -f yyyy
        checksumType = 'sha256'
	}
}

function global:au_SearchReplace {
    @{
         "midi2lr.nuspec" = @{
             "(\<copyright\>).*?(\</copyright\>)" = "`${1}$($Latest.Year) &#169; Rory Jaffe`$2"
            #  "(\<version\>).*?(\</version\>)" = "`${1}$($Latest.NuspecVersion)`$2" # for testing purposes, resets to previous version
         }
         "tools\chocolateyInstall.ps1" = @{
            "(url\s*=\s*)('.*')"      = "`$1'$($Latest.url)'"
            "(checksum\s*=\s*)('.*')" = "`$1'$($Latest.checksum)'"
            "(checksumType\s*=\s*)('.*')" = "`$1'$($Latest.checksumType)'"
        }
     }
 }
 function global:au_BeforeUpdate() {

    $global:ProgressPreference="SilentlyContinue"
    $Latest.checksum = Get-RemoteChecksum $Latest.url $Latest.checksumType

	# Update .nuspec file with multiline support, Carl!!!
	$spec = Get-Content "midi2lr.nuspec" -Raw -Encoding "UTF8"
	$spec = $spec -replace "(\<releaseNotes\>)(?s:.*?)(\<\/releaseNotes\>)", "`${1}$($Latest.notes)`$2"
	$spec.trim() | out-file "midi2lr.nuspec" -Encoding "UTF8"
 }

 try {
	update -ChecksumFor none
} catch {
    $ignore = 'Unable to connect to the remote server'
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
}
