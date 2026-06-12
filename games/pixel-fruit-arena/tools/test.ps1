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

Write-Output "Tests passed: fruits, stage, character manifest, release guard."
