
# This file provides verification of ZIP file shipped with this package.
#
# As nginx.org for each release provide a PGP signature, we will have to
# download signing public key, signature and verify it with bin\nginx.zip

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

### Info on files
# Though, nginx has specific public hey titled for "signing packages and repositories",
# it is known that Maxim Dounin’s PGP public key is used to sign Windows zip releases
# https://nginx.org/en/pgp_keys.html
Invoke-WebRequest "https://nginx.org/keys/mdounin.key" -UseBasicParsing -OutFile "$toolsDir\..\bin\mdounin.key"

# Release zip obtained from
# https://nginx.org/en/download.html
# file is already stored as bin\nginx.zip

# Get original signature from
# https://nginx.org/en/download.html
Invoke-WebRequest "https://nginx.org/download/nginx-1.26.2.zip.asc" -UseBasicParsing -OutFile "$toolsDir\..\bin\nginx-1.26.2.zip.asc"

### Preperation
# Check that we have GPG 
choco install gpg4win -y | out-null

### Verify
# Import keys and verify ZIP file against the signature
gpg --import "$toolsDir\..\bin\mdounin.key"
gpg --verify "$toolsDir\..\bin\nginx-1.26.2.zip.asc" "$toolsDir\..\bin\nginx.zip"
