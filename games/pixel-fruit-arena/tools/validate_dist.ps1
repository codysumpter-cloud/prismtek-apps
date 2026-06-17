$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$dist = Join-Path $ProjectRoot "dist"
$requiredEntries = @("index.html", "app.webmanifest", "sw.js", "src", "data", "assets")

if (-not (Test-Path -LiteralPath $dist)) {
  throw "dist/ is missing. Run the build script first."
}

foreach ($entry in $requiredEntries) {
  $absolute = Join-Path $dist $entry
  if (-not (Test-Path -LiteralPath $absolute)) {
    throw "dist/$entry is missing from the web build."
  }
}

$referencePath = Join-Path $dist "assets/reference"
if (Test-Path -LiteralPath $referencePath) {
  throw "dist/assets/reference must not be present in release builds."
}

$gifLeaks = @(Get-ChildItem -LiteralPath $dist -Recurse -File -Filter "*.gif" -ErrorAction SilentlyContinue)
if ($gifLeaks.Count -gt 0) {
  $gifLeaks | ForEach-Object { Write-Error $_.FullName }
  throw "GIF assets leaked into release build."
}

$fileCount = @(Get-ChildItem -LiteralPath $dist -Recurse -File -ErrorAction SilentlyContinue).Count
Write-Output "Validated Pixel Fruit Arena dist: $fileCount files, no reference assets, no GIF leaks."
