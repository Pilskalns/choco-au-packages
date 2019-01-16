function global:au_GetLatest {
	
	$htmlstring = Invoke-WebRequest "http://nginx.org/en/download.html" -UseBasicParsing
	
	$Matches = @{version = "0.0.0"; nginxVersion = "0.0.0"; url = ""} # defaults in case remote site changes
	$versionregex = "$type\sversion.*?<table.*?""(?<url>\/download\/nginx-\S*?\.zip)"".*?windows-(?<version>[0-9\.]*?)<\/a.*?<\/table"

	$htmlstring -match $versionregex | out-null

	@{
		Version = $Matches.version+ $(If($type -eq 'mainline'){"-mainline"} else {""})
		nginxVersion = $Matches.version -replace "(\d+)\.(\d+)\.(\d+).*",'$1.$2.$3'
		url 	= "https://nginx.org"+$Matches.url
		Year	= get-date -f yyyy
	}
}
function global:au_SearchReplace {
    @{
         "nginx-service.nuspec" = @{
             "(\<copyright\>).*?(\</copyright\>)" = "`${1}$($Latest.Year) &#169; Nginx, Inc.`$2"
             # "(\<version\>).*?(\</version\>)" = "`${1}$($Latest.NuspecVersion)`$2" # for testing purposes, leaves previous version
         }
     }
}

function global:au_AfterUpdate() {
	
	$version = $Latest.nginxVersion
	$versionRegex = $version.replace(".","\.")

	choco install 7zip -y | out-null

	(Test-Path "tmp\nginx-$version\") -And (Get-Childitem "tmp\nginx-$version\*" -Recurse | Remove-Item -Recurse -Force)

	(New-Object System.Net.WebClient).DownloadFile($Latest.url, "$pwd\tmp\nginx.zip")
	7z.exe x tmp\nginx.zip -otmp -aoa -r
	Copy-Item "tmp\nginx-$version\*" "bin\" -Recurse -Force
	"taking care of race condition myself" | Out-File "bin\nginx.exe.ignore"
	
	# Scrape for changelog text
	$changesText = "Changes not found"
	$changes = Get-Content "tmp\nginx-$version\docs\CHANGES" -raw
	if($changes -match '(?smi)(Changes\s+with\s+nginx\s+'+$versionRegex+'.*?$)(?smi)(.*?)Changes\s+with\s+nginx'){
		$changesText = $matches[2].trim()
		$changesText = $changesText -replace  ".*?(\*\))",'$1'
		$changesText = $changesText -replace  "       ",'   '
		$changesText = "<![CDATA["+$changesText+"]]>"
	}
	
	# Update .nuspec file with multiline support, Carl!!!
	$spec = Get-Content "nginx-service.nuspec" -Raw -Encoding "UTF8"
	$spec = $spec -replace "(\<releaseNotes\>)(?s:.*?)(\<\/releaseNotes\>)", "`${1}$changesText`$2"
	$spec = $spec -replace "(?i)(migration from 1\.6\.2\.1 to ).*", "`${1}$($Latest.Version)"
	$spec.trim() | out-file "nginx-service.nuspec" -Encoding "UTF8"

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
	$mainConf = Get-Content "tmp\nginx-$version\conf\nginx.conf" -raw
	$mainConf = $mainConf -replace "(?s)(location.*?{.*?})",""
	$mainConf = $mainConf -replace "(?s)(server.*?{.*?})",""
	$mainConf = $mainConf -replace "(?m)(^\s*#\s*$)",""
	$mainConf = $mainConf -replace "(?m)(^\s*#\s*HTTPS\s*$)",""
	$mainConf = $mainConf -replace "(?m)(^\s*#\s*another\svirtual\shost.*$)",""
	$mainConf = $mainConf -replace "(?s)(http.*?{)(.*?)(})","`$1`$2$include`$3"

	$mainConf = $warning+$mainConf

	$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
	[System.IO.File]::WriteAllLines("$pwd\tools\conf\nginx.conf", $mainConf, $Utf8NoBomEncoding)
}
