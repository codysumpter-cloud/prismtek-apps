param(
  [string]$GameDir = "."
)

$resolvedGameDir = Resolve-Path $GameDir
$indexPath = Join-Path $resolvedGameDir "index.html"
$packagePath = Join-Path $resolvedGameDir "package.json"

if (-not (Test-Path -LiteralPath $indexPath)) {
  throw "missing index.html in $resolvedGameDir"
}

if (-not (Test-Path -LiteralPath $packagePath)) {
  throw "missing package.json in $resolvedGameDir"
}

$html = Get-Content -Raw -LiteralPath $indexPath
if ($html -notmatch 'id="game-root"') {
  throw "index.html must include game-root mount point"
}

if ($html -notmatch 'arcade-core\.js') {
  throw "index.html must import the shared arcade runtime"
}

if ($html -notmatch 'createArcadeGame') {
  throw "index.html must boot a playable game"
}

$pkg = Get-Content -Raw -LiteralPath $packagePath | ConvertFrom-Json
if (-not $pkg.scripts.dev) {
  throw "package.json must define dev script"
}

if (-not $pkg.scripts.test) {
  throw "package.json must define test script"
}

Write-Output "Arcade smoke passed: $([System.IO.Path]::GetFileName($resolvedGameDir))"
