
$releases = 'https://chocolatey.org/api/v2/FindPackagesById()?id=%27nginx%27&$orderby=IsLatestVersion%20desc&$top=1'

function global:au_SearchReplace {
   @{
        "nginx-service.nuspec" = @{
            "(\<dependency\s+?id=""nginx""\s+?version=""\[).*?(\])" = "`${1}$($Latest.nginxVersion)`$2"

			"(\<copyright\>).*?(\</copyright\>)" = "`${1}$($Latest.Year) &#169; Nginx, Inc.`$2"
			# "(\<version\>).*?(\</version\>)" = "`${1}$($Latest.NuspecVersion)`$2" # for testing purposes, leaves previous version
        }
		".\README.md" = @{
			"(?i)(migration from 1\.6\.2\.1 to ).*"        = "`${1}$($Latest.nginxVersion)"
		}
    }
}

function global:au_GetLatest {


	[xml]$info = (New-Object System.Net.WebClient).DownloadString($releases)
	$version = $info.feed.entry.properties.Version

  @{
    Version = $version
	Year = get-date -f yyyy
  }
}

function global:au_BeforeUpdate() {
	$Latest.nginxVersion = $Latest.Version -replace "(\d+)\.(\d+)\.(\d+).*",'$1.$2.$3'
}
function global:au_AfterUpdate() {
	$version = $Latest.nginxVersion
	$versionRegex = $version.replace(".","\.")

	choco install nginx --version=$version | out-null

	# Scrape for changelog text
	$changesText = "Changes not found"
	$changes = gc $env:ChocolateyInstall"\lib\nginx\tools\nginx-$version\docs\CHANGES" -raw
	if($changes -match '(?smi)(Changes\s+with\s+nginx\s+'+$versionRegex+'.*?$)(?smi)(.*?)Changes\s+with\s+nginx'){
		$changesText = $matches[2].trim()
		$changesText = $changesText -replace  ".*?(\*\))",'$1'
		$changesText = $changesText -replace  "       ",'   '
		$changesText = "<![CDATA["+$changesText+"]]>"
	}

	# Update .nuspec file with multiline support, Carl!!!
	$spec = gc "nginx-service.nuspec" -Raw -Encoding "UTF8"
	$spec = $spec -replace "(\<releaseNotes\>)(?s:.*?)(\<\/releaseNotes\>)", "`${1}$changesText`$2"
	$spec = $spec -replace "(?i)(migration from 1\.6\.2\.1 to ).*", "`${1}$($Latest.Version)"
	$spec.trim() | out-file "nginx-service.nuspec" -Encoding "UTF8"

	# Include original license file
	$license = gc $env:ChocolateyInstall"\lib\nginx\tools\nginx-$version\docs\LICENSE" -raw
	$license | out-file "tools\LICENSE.txt" -Encoding "UTF8"

	# Generate conf file here, complex regex bla bla so it doesn't brake on client machine
	# Version will match as dependency is exact one
	$warning = @"
#
#    DURING UPDATE THIS FILE WILL BE OVERWRITTEN
#    IF YOU HAVE IMPORTANT IMPROVEMENTS, CONTACT
#    ME ON chocolatey.org/packages/nginx-service
#

"@
	$include = @"
    # PLACE YOUR CUSTOM {server}.conf FILES INSIDE
    # C:/tools/nginx/conf.d/
    include ../conf.d/server*.conf;


"@
	# Output MAIN CONFIG FILE
	$mainConf = gc $env:ChocolateyInstall"\lib\nginx\tools\nginx-$version\conf\nginx.conf" -raw
	$mainConf = $mainConf -replace "(?s)(location.*?{.*?})",""
	$mainConf = $mainConf -replace "(?s)(server.*?{.*?})",""
	$mainConf = $mainConf -replace "(?m)(^\s*#\s*$)",""
	$mainConf = $mainConf -replace "(?m)(^\s*#\s*HTTPS\s*$)",""
	$mainConf = $mainConf -replace "(?m)(^\s*#\s*another\svirtual\shost.*$)",""
	$mainConf = $mainConf -replace "(?s)(http.*?{)(.*?)(})","`$1`$2$include`$3"

	$mainConf = $warning+$mainConf

	# $mainConf | out-file "tools\conf\nginx.conf" -Encoding "UTF8"

	$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
	[System.IO.File]::WriteAllLines("$pwd\tools\conf\nginx.conf", $mainConf, $Utf8NoBomEncoding)
}
try {
	update -ChecksumFor none
} catch {
    $ignore = 'Unable to connect to the remote server'
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
}
