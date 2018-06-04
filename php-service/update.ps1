
$releases = 'https://chocolatey.org/api/v2/FindPackagesById()?id=%27php%27&$orderby=IsLatestVersion%20desc&$top=1'

function global:au_SearchReplace {
   @{
        "php-service.nuspec" = @{
            "(\<dependency\s+?id=""php""\s+?version=""\[).*?(\])" = "`${1}$($Latest.phpVersion)`$2"

			"(\<copyright\>).*?(\</copyright\>)" = "`${1}$($Latest.Year) &#169; PHP Group`$2"
			# "(\<version\>).*?(\</version\>)" = "`${1}$($Latest.NuspecVersion)`$2" # for testing purposes, leaves previous version
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
	$Latest.phpVersion = $Latest.Version -replace "(\d+)\.(\d+)\.(\d+).*",'$1.$2.$3'
	$Latest.phpInstallLocation = "$($Env:ChocolateyToolsLocation)\php{0}" -f ($Latest.phpVersion -replace '\.').Substring(0,2)
}
function global:au_AfterUpdate() {
	$version = $Latest.phpVersion
	$versionRegex = $version.replace(".","\.")
	$installDir = $Latest.phpInstallLocation
	
	write-host ""
	write-host "Trying to install PHP $version" -ForegroundColor Green
	write-host ""
	
	&choco install php --version=$version --force --params "'/InstallDir:$installDir'" | out-null

	

	# Scrape for changelog text
	$changesText = ""
	$changes = Get-Content "$($installDir)\news.txt" -raw
	# Write-Host $changes
	if($changes -match '(?smi)(,\s+PHP\s+'+$versionRegex+'.*?$)(?smi)(.*?)\d{1,2}\s\w{2,8}\s\d{4},\sPHP\s\d+\.\d+\.\d+'){
		$changesText = $matches[2].trim()
		$changesText = "<![CDATA["+$changesText+"]]>"
	}
	
	# Update .nuspec file with multiline support, Carl!!!
	$spec = Get-Content "php-service.nuspec" -Raw -Encoding "UTF8"
	$spec = $spec -replace "(\<releaseNotes\>)(?s:.*?)(\<\/releaseNotes\>)", "`${1}$changesText`$2"
	$spec.trim() | out-file "php-service.nuspec" -Encoding "UTF8"
	
	# Include original license file
	$license = Get-Content "$($installDir)\license.txt" -raw
	$license | out-file "tools\LICENSE.txt" -Encoding "UTF8"


	# # Remove comments from install-scripts
	# $minFiles = @(
	# 	'tools\chocolateyinstall.ps1'
	# 	'tools\chocolateyuninstall.ps1'
	# )
	# $minFiles | % {
	# 	$file = $_
	# 	Get-Content $file | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $file+".~" -en utf8; mv -fo $file+".~" $file
	# }
}

try {
	update -ChecksumFor none
} catch {
    $ignore = 'Unable to connect to the remote server'
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' }  else { throw $_ }
}
