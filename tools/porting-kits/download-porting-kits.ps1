param(
  [string]$DownloadRoot = $env:PRISMTEK_PORTING_KITS_DIR
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..' '..')
$ManifestPath = Join-Path $RepoRoot 'tools/porting-kits/porting-kits.manifest.json'

if ([string]::IsNullOrWhiteSpace($DownloadRoot)) {
  $DownloadRoot = Join-Path $RepoRoot '.porting-kits'
}

$ChecksumFile = Join-Path $DownloadRoot 'SHA256SUMS.txt'

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw 'Node.js is required to read the manifest. Install Node.js LTS first.'
}

New-Item -ItemType Directory -Force -Path $DownloadRoot | Out-Null
'' | Set-Content -Path $ChecksumFile -Encoding utf8

Write-Host "Using manifest: $ManifestPath"
Write-Host "Download root:  $DownloadRoot"

$Manifest = Get-Content -Raw -Path $ManifestPath | ConvertFrom-Json

foreach ($Kit in $Manifest.kits) {
  foreach ($Source in $Kit.sources) {
    if ($Source.automated -and $Source.destination) {
      $Destination = Join-Path $DownloadRoot $Source.destination
      $DestinationDir = Split-Path -Parent $Destination
      New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null

      if (Test-Path $Destination) {
        Write-Host "Already downloaded: $($Source.destination)"
      } else {
        Write-Host "Downloading $($Source.id) -> $($Source.destination)"
        Invoke-WebRequest -Uri $Source.url -OutFile $Destination -MaximumRedirection 10
      }

      $Hash = Get-FileHash -Algorithm SHA256 -Path $Destination
      "$($Hash.Hash.ToLowerInvariant())  $($Source.destination)" | Add-Content -Path $ChecksumFile -Encoding utf8

      if ($Source.reviewRequired) {
        Write-Host "Review required before use: $($Source.destination)" -ForegroundColor Yellow
      }
    }
  }
}

Write-Host "Wrote checksums: $ChecksumFile"
Write-Host 'Next: npm run porting-kits:verify'
