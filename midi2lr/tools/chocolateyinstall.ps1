$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE'
  softwareName  = 'midi2lr*'

  url           = 'https://github.com/rsjaffe/MIDI2LR/releases/download/v5.3.0.2/MIDI2LR-5.3.0.2-windows-installer.exe'
  checksum      = '60f299238e496fd78122d588161d97437ce29ea35c3c0a0d1ed9d8c69c3e7e1d'
  checksumType  = 'sha256'
 
  silentArgs    = '--mode unattended --unattendedmodeui none'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
