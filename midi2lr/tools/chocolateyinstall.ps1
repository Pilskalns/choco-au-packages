$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE'
  softwareName  = 'midi2lr*'

  url           = 'https://github.com/rsjaffe/MIDI2LR/releases/download/v4.1.1.0/MIDI2LR-4.1.1.0-windows-installer.exe'
  checksum      = 'ff164a56ac227abb6ff26fc065d68a86409cff4dd5ef80d6223b6aade0bca0f6'
  checksumType  = 'sha256'
 
  silentArgs    = '--mode unattended --unattendedmodeui none'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
