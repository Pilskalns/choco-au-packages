$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'EXE'
  softwareName  = 'midi2lr*'

  url           = 'https://github.com/rsjaffe/MIDI2LR/releases/download/v5.1.0.0/MIDI2LR-5.1.0.0-windows-installer.exe'
  checksum      = 'd02aca835120cca35f9c21c9fe7636ce885a78fd17b485e8041f5e66160be816'
  checksumType  = 'sha256'
 
  silentArgs    = '--mode unattended --unattendedmodeui none'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
