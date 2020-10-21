$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE'
  softwareName  = 'midi2lr*'

  url           = 'https://github.com/rsjaffe/MIDI2LR/releases/download/v4.0.2.1/MIDI2LR-4.0.2.1-windows-installer.exe'
  checksum      = 'dd2f9d985343148f1e10dfa9709f3c11c70ccb41ba16dd9c70ce92b4f17304dd'
  checksumType  = 'sha256'
 
  silentArgs    = '--mode unattended --unattendedmodeui none'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
