$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE'
  softwareName  = 'midi2lr*'

  url           = 'https://github.com/rsjaffe/MIDI2LR/releases/download/v3.4.7.0/MIDI2LR-3.4.7.0-windows-installer.exe'
  checksum      = '5a3431ae08d82c73c936adf51225e27d246cf9ae79a873ebbac9e99b65eb0c5a'
  checksumType  = 'sha256'
 
  silentArgs    = '--mode unattended --unattendedmodeui none'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
