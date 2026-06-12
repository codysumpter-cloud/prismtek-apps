$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$dist = Join-Path $ProjectRoot "dist"
if (Test-Path -LiteralPath $dist) {
  Remove-Item -LiteralPath $dist -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $dist | Out-Null
foreach ($entry in @("index.html", "src", "data", "assets")) {
  Copy-Item -LiteralPath (Join-Path $ProjectRoot $entry) -Destination (Join-Path $dist $entry) -Recurse -Force
}
$referencePath = Join-Path $dist "assets/reference"
if (Test-Path -LiteralPath $referencePath) {
  Remove-Item -LiteralPath $referencePath -Recurse -Force
}
if (Test-Path -LiteralPath $referencePath) {
  throw "Reference assets leaked into release build"
}
$gifLeaks = @(Get-ChildItem -LiteralPath $dist -Recurse -File -Filter "*.gif" -ErrorAction SilentlyContinue)
if ($gifLeaks.Count -gt 0) {
  $paths = $gifLeaks | ForEach-Object { $_.FullName.Substring($dist.Path.Length + 1) }
  throw "GIF assets leaked into release build:`n$($paths -join "`n")"
}
Write-Output "Build complete. Reference assets and GIF files excluded from release artifacts."
