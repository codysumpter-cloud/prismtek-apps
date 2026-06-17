param(
  [string]$Downloads = (Join-Path $env:USERPROFILE "Downloads")
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Target = Join-Path $ProjectRoot "assets/reference/onepiece-test/runtime"
New-Item -ItemType Directory -Force -Path $Target | Out-Null

$files = @(
  "OnePiece animation 1.gif",
  "OnePiece animation 2.gif",
  "OnePiece animation 3.gif",
  "OnePiece animation 4.gif",
  "OnePiece animation 5.gif",
  "OnePiece animation 7.gif",
  "OnePiece animation 8.gif",
  "Monkey D. Dragon - animation sheet (all frames).png",
  "SHANKS 8bit - Frames-Sheet.png",
  "enies_lobby_tex.png"
)

$copied = @()
foreach ($file in $files) {
  $source = Join-Path $Downloads $file
  if (Test-Path -LiteralPath $source -PathType Leaf) {
    Copy-Item -LiteralPath $source -Destination (Join-Path $Target $file) -Force
    $copied += $file
  } else {
    Write-Warning "Missing local reference asset: $source"
  }
}

$manifest = [ordered]@{
  mode = "onepiece-test-local"
  warning = "Local fan/dev reference assets only. Do not commit, ship, or include in release artifacts."
  effects = [ordered]@{
    fireball = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 1.gif"; width = 240; height = 80; scale = 0.82; offsetX = 74; offsetY = -12 }
    flame_dash = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 2.gif"; width = 240; height = 80; scale = 0.82; offsetX = 64; offsetY = -8 }
    burning_uppercut = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 7.gif"; width = 240; height = 80; scale = 0.82; offsetX = 38; offsetY = -24 }
    ice_spike = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 3.gif"; width = 240; height = 80; scale = 0.78; offsetX = 70; offsetY = -10 }
    freeze_field = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 8.gif"; width = 240; height = 80; scale = 0.86; offsetX = 18; offsetY = -12 }
    lightning_bolt = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 4.gif"; width = 240; height = 80; scale = 0.9; offsetX = 78; offsetY = -12 }
    blink_dash = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 5.gif"; width = 240; height = 80; scale = 0.76; offsetX = 56; offsetY = -8 }
    chain_shock = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 4.gif"; width = 240; height = 80; scale = 0.86; offsetX = 48; offsetY = -12 }
    pull_field = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 8.gif"; width = 240; height = 80; scale = 0.86; offsetX = 26; offsetY = -10 }
    shadow_burst = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 5.gif"; width = 240; height = 80; scale = 0.88; offsetX = 42; offsetY = -10 }
    null_zone = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 8.gif"; width = 240; height = 80; scale = 0.96; offsetX = 14; offsetY = -10 }
    stretch_punch = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 2.gif"; width = 240; height = 80; scale = 0.72; offsetX = 82; offsetY = -8 }
    bounce_jump = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 7.gif"; width = 240; height = 80; scale = 0.74; offsetX = 28; offsetY = -22 }
    giant_fist = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 1.gif"; width = 240; height = 80; scale = 0.92; offsetX = 78; offsetY = -12 }
    pull = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 8.gif"; width = 240; height = 80; scale = 0.86; offsetX = 32; offsetY = -10 }
    slam = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 5.gif"; width = 240; height = 80; scale = 0.96; offsetX = 28; offsetY = -8 }
    float_strike = @{ src = "assets/reference/onepiece-test/runtime/OnePiece animation 7.gif"; width = 240; height = 80; scale = 0.8; offsetX = 42; offsetY = -24 }
  }
  stageTexture = @{ src = "assets/reference/onepiece-test/runtime/enies_lobby_tex.png" }
  unusedReferenceSheets = @(
    "assets/reference/onepiece-test/runtime/Monkey D. Dragon - animation sheet (all frames).png",
    "assets/reference/onepiece-test/runtime/SHANKS 8bit - Frames-Sheet.png"
  )
}

$manifestPath = Join-Path $Target "manifest.json"
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
"Reference assets only. Not for release." | Set-Content -LiteralPath (Join-Path $Target "README_REFERENCE_ASSETS.txt") -Encoding UTF8

Write-Output "Installed $($copied.Count) local One Piece reference assets to $Target"
Write-Output "Run locally with: http://localhost:4173/?referenceAssets=true"
