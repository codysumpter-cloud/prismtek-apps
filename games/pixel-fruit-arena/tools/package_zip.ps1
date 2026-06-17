$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$dist = Join-Path $ProjectRoot "dist"
$artifacts = Join-Path $ProjectRoot "artifacts"
$zipPath = Join-Path $artifacts "pixel-fruit-arena-web.zip"

powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "validate_dist.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

New-Item -ItemType Directory -Force -Path $artifacts | Out-Null
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

$distContents = Join-Path $dist "*"
Compress-Archive -Path $distContents -DestinationPath $zipPath -Force

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  $entries = @($zip.Entries | ForEach-Object { $_.FullName })
  if ($entries -notcontains "index.html") {
    throw "ZIP must contain index.html at the archive root."
  }
  $leaks = @($entries | Where-Object { $_ -match '(^|/)assets/reference/' -or $_ -match '\.gif$' })
  if ($leaks.Count -gt 0) {
    $leaks | ForEach-Object { Write-Error $_ }
    throw "Reference assets or GIF files leaked into ZIP."
  }
  Write-Output "Created artifacts/pixel-fruit-arena-web.zip ($($entries.Count) entries)."
}
finally {
  $zip.Dispose()
}
