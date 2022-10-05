Import-Module AU
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

$history_page = 'https://www.stardock.com/products/windowblinds/history'

function global:au_GetLatest {
  $releases = Invoke-WebRequest -Uri $history_page -UseBasicParsing

  $Url = 'https://cdn.stardock.us/downloads/public/software/windowblinds/WindowBlinds11_setup.exe?a=sd'
  
  $re = "WindowBlinds (?<version>[\d\.]+[\d\.]+)"
  $version = $releases -match $re | ForEach-Object { $Matches.version }
  if ($version.length -eq 2) {
    # we must have a revision number
    $version += ".0.0"
  }
  $ChecksumType = 'sha256'

  @{
    Url32             = $Url
    Version           = $version
    ChecksumType32    = $ChecksumType
  }
}

function global:au_BeforeUpdate {
  $Latest.Checksum32 = Get-RemoteChecksum $Latest.Url32 -Algorithm $Latest.ChecksumType32
}

function global:au_SearchReplace {
  @{
      'tools\chocolateyInstall.ps1' = @{
          "(^[$]url\s*=\s*)('.*')"          = "`$1'$($Latest.Url32)'"
          "(^[$]checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
          "(^[$]checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
      }
  }
}

Update-Package -ChecksumFor none