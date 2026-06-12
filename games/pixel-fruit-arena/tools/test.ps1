$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

$fruits = Get-Content -Raw -LiteralPath (Join-Path $ProjectRoot "data/fruits/fruits.json") | ConvertFrom-Json
if (@($fruits).Count -ne 6) { throw "six fruits are required" }
foreach ($fruit in $fruits) {
  if (@($fruit.abilities).Count -ne 3) { throw "$($fruit.id) must have three abilities" }
  if (-not $fruit.awakening) { throw "$($fruit.id) needs awakening" }
}

$stage = Get-Content -Raw -LiteralPath (Join-Path $ProjectRoot "data/stages/sky_ruins.json") | ConvertFrom-Json
if (@($stage.platforms).Count -lt 3) { throw "stage needs multiple platforms" }
if (@($stage.respawns).Count -lt 4) { throw "stage needs four respawn points" }

$character = Get-Content -Raw -LiteralPath (Join-Path $ProjectRoot "assets/characters/prismtek_placeholder_character.json") | ConvertFrom-Json
if ($character.sprite_width -ne 64 -or $character.sprite_height -ne 64) { throw "character must be 64x64" }
if (@($character.animations).Count -ne 10) { throw "character must define ten animations" }
if ($env:USE_REFERENCE_TEST_ASSETS -eq "true" -and $env:NODE_ENV -eq "production") { throw "reference assets cannot be used in production" }

$requiredAssets = @(
  "assets/characters/tiny-hero/pink/idle_4.png",
  "assets/characters/tiny-hero/pink/run_6.png",
  "assets/characters/tiny-hero/owlet/attack1_4.png",
  "assets/characters/tiny-hero/dude/hurt_4.png",
  "assets/stages/four-seasons/four-seasons-tileset.png",
  "assets/licenses/craftpix-tiny-hero-license.txt",
  "assets/licenses/rottingpixels-four-seasons.txt"
)
foreach ($asset in $requiredAssets) {
  if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $asset))) { throw "missing runtime asset: $asset" }
}

$referenceFiles = Get-ChildItem -LiteralPath (Join-Path $ProjectRoot "assets/reference/onepiece-test") -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".gitkeep" }
if ($env:NODE_ENV -eq "production" -and $referenceFiles) { throw "reference test assets cannot be present in production validation" }

$nodeCommand = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCommand) {
  Push-Location $ProjectRoot
  try {
    & node tools/test.mjs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  finally {
    Pop-Location
  }
} else {
  Write-Warning "Node.js not found on PATH; skipped runtime JS gameplay smoke validation."
}

Write-Output "Tests passed: fruits, stage, character manifest, release guard."
