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
Write-Output "Build complete. USE_REFERENCE_TEST_ASSETS forced false for release artifacts."
