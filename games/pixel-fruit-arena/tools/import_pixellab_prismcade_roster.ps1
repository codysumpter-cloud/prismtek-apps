param(
  [string]$SourceRoot = (Join-Path $env:USERPROFILE "Downloads"),
  [string]$OutputRoot = (Join-Path (Resolve-Path ".").Path "assets\characters\prismcade-pixellab"),
  [switch]$AllowDownload
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

$FrameSize = 64
$FrameCount = 4
$Directions = @("east", "south-east", "south", "west", "north-east", "north", "south-west", "north-west")
$LoopAnimations = @("idle", "walk", "run", "victory")
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$Characters = @(
  @{
    Id = "prismcade_buddy"
    DisplayName = "Buddy"
    SourceVariantId = "buddy"
    SourceCharacterId = "7a14aefe-6c41-4290-ba26-a149d93725fb"
    SourceZipNames = @("Buddy_detail_restored_clean.zip", "Buddy_detail_restored.zip", "Buddy.zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/7a14aefe-6c41-4290-ba26-a149d93725fb/download"
    Folder = "Buddy"
    AnimationFidelity = "source-animation-normalized"
    AnimationMap = @{
      idle = @("idle", "Breathing_Idle")
      walk = @("Walk", "Walking")
      run = @("Walk", "Running")
      jump = @("Push_Object", "charge", "charge_animation_Keep_the_exact_same_Buddy_charact")
      fall = @("Pull_Object", "Taking_Punch", "hurt")
      attack = @("melee_thrust", "Push_Object", "Taking_Punch")
      special = @("Fireball", "projectile", "cast")
      hurt = @("Taking_Punch", "hurt")
      knockout = @("KO", "defeat")
      victory = @("victory", "victory_animation_Keep_the_exact_same_Buddy_charac", "happy_animation_Keep_the_exact_same_Buddy_characte")
    }
  },
  @{
    Id = "prismcade_prismtek"
    DisplayName = "Prismtek"
    SourceVariantId = "prismtek"
    SourceCharacterId = "ce607761-915c-46ca-9f9c-9eb51cbd30eb"
    SourceZipNames = @("Prismtek.zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/ce607761-915c-46ca-9f9c-9eb51cbd30eb/download"
    Folder = "Prismtek"
    AnimationFidelity = "source-animation-normalized"
    AnimationMap = @{
      idle = @("Breathing_Idle", "Fight_Stance_Idle")
      walk = @("Walking")
      run = @("Running")
      jump = @("Crouching", "Pull_Object")
      fall = @("Crouching", "Pull_Object")
      attack = @("Push_Object", "Fight_Stance_Idle")
      special = @("Pull_Object", "Push_Object")
      hurt = @("Crouching", "Fight_Stance_Idle")
      knockout = @("Crouching")
      victory = @("Breathing_Idle", "Fight_Stance_Idle")
    }
  },
  @{
    Id = "prismcade_prismtek_jones"
    DisplayName = "Prismtek Jones"
    SourceVariantId = "prismtek-jones"
    SourceCharacterId = "eb325608-c78f-4249-906f-64b831834a28"
    SourceZipNames = @("Prismtek_Jones.zip", "Prismtek Jones.zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/eb325608-c78f-4249-906f-64b831834a28/download"
    Folder = "Prismtek_Jones"
    AnimationFidelity = "rotation-derived"
    AnimationMap = @{}
  },
  @{
    Id = "prismcade_female_blue_hoodie"
    DisplayName = "Female Blue Hoodie"
    SourceVariantId = "female-character-blue-hoodie"
    SourceCharacterId = "a0bf4028-6285-4cec-870c-8723b5fedbed"
    SourceZipNames = @("Female_Character_Blue_Hoodie.zip", "Create_a_full-body_64x64_pixel.zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/a0bf4028-6285-4cec-870c-8723b5fedbed/download"
    Folder = "Female_Character_Blue_Hoodie"
    AnimationFidelity = "rotation-derived"
    AnimationMap = @{}
  },
  @{
    Id = "prismcade_ponytail_guy"
    DisplayName = "Ponytail Guy"
    SourceVariantId = "ponytail-guy"
    SourceCharacterId = "90611122-97c7-4b92-acd9-db41084445e9"
    SourceZipNames = @("Ponytail_Guy.zip", "Ponytail_Guy (1).zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/90611122-97c7-4b92-acd9-db41084445e9/download"
    Folder = "Ponytail_Guy"
    AnimationFidelity = "rotation-derived"
    AnimationMap = @{}
  },
  @{
    Id = "prismcade_prismtek_pixel_god"
    DisplayName = "Prismtek Pixel God"
    SourceVariantId = "prismtek-pixel-god"
    SourceCharacterId = "65a80608-9b8b-4174-a4bf-b9708fc70d38"
    SourceZipNames = @("Prismtek_Pixel_God.zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/65a80608-9b8b-4174-a4bf-b9708fc70d38/download"
    Folder = "Prismtek_Pixel_God"
    AnimationFidelity = "rotation-derived"
    AnimationMap = @{}
  },
  @{
    Id = "prismcade_prismbot_pixel_god"
    DisplayName = "PrismBot Pixel God"
    SourceVariantId = "prismbot-pixel-god"
    SourceCharacterId = "9ff7bf55-bc38-4e8f-acc7-aa1b7ce157e6"
    SourceZipNames = @("PrismBot_Pixel_God.zip")
    DownloadUrl = "https://api.pixellab.ai/mcp/characters/9ff7bf55-bc38-4e8f-acc7-aa1b7ce157e6/download"
    Folder = "PrismBot_Pixel_God"
    AnimationFidelity = "rotation-derived"
    AnimationMap = @{}
  }
)

function Resolve-SourcePacket($Character) {
  foreach ($name in $Character.SourceZipNames) {
    $candidate = Join-Path $SourceRoot $name
    if (Test-Path -LiteralPath $candidate) {
      return @{ Path = $candidate; PacketName = $name; Source = "local-downloads" }
    }
  }

  if (-not $AllowDownload) {
    throw "Missing source packet for $($Character.DisplayName). Looked under $SourceRoot. Re-run with -AllowDownload to fetch the registry export URL."
  }

  $downloadRoot = Join-Path ([System.IO.Path]::GetTempPath()) "prismtek-pixellab-intake"
  New-Item -ItemType Directory -Force -Path $downloadRoot | Out-Null
  $downloadPath = Join-Path $downloadRoot "$($Character.Id).zip"
  Invoke-WebRequest -Uri $Character.DownloadUrl -OutFile $downloadPath -UseBasicParsing -TimeoutSec 90
  return @{ Path = $downloadPath; PacketName = "$($Character.Id).zip"; Source = "pixellab-download-url" }
}

function Write-Utf8NoBom($Path, $Text) {
  [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Read-Metadata($Archive) {
  $entry = $Archive.Entries | Where-Object { $_.FullName -eq "metadata.json" } | Select-Object -First 1
  if (-not $entry) { return $null }
  $reader = New-Object System.IO.StreamReader($entry.Open())
  try { return ($reader.ReadToEnd() | ConvertFrom-Json) }
  finally { $reader.Dispose() }
}

function Get-EntryByName($Archive, $Name) {
  return $Archive.Entries | Where-Object { $_.FullName -eq $Name } | Select-Object -First 1
}

function Get-RotationFrame($Archive, $Folder) {
  foreach ($direction in $Directions) {
    $entry = Get-EntryByName $Archive "$Folder/rotations/$direction.png"
    if ($entry) { return @{ Entries = @($entry); Source = "rotations/$direction"; Synthetic = $true } }
  }
  throw "No rotation frame found under $Folder/rotations"
}

function Get-AnimationFrames($Archive, $Folder, $AnimationNames) {
  foreach ($animationName in $AnimationNames) {
    foreach ($direction in $Directions) {
      $prefix = "$Folder/animations/$animationName/$direction/"
      $entries = @($Archive.Entries | Where-Object {
        $_.FullName.StartsWith($prefix) -and $_.FullName.ToLowerInvariant().EndsWith(".png")
      } | Sort-Object FullName)
      if ($entries.Count -gt 0) {
        return @{ Entries = $entries; Source = "animations/$animationName/$direction"; Synthetic = $false }
      }
    }
  }
  return $null
}

function Get-SyntheticOffset($AnimationName, $Index) {
  $patterns = @{
    idle = @(@(0,0), @(0,-1), @(0,0), @(0,1))
    walk = @(@(-2,1), @(0,0), @(2,1), @(0,0))
    run = @(@(-3,2), @(1,0), @(3,2), @(-1,0))
    jump = @(@(0,0), @(0,-5), @(0,-7), @(0,-4))
    fall = @(@(0,-4), @(0,-2), @(0,0), @(0,2))
    attack = @(@(-1,0), @(2,0), @(5,0), @(1,0))
    special = @(@(0,0), @(0,-2), @(0,-4), @(0,-1))
    hurt = @(@(2,0), @(-2,1), @(1,0), @(0,0))
    knockout = @(@(0,0), @(0,3), @(0,6), @(0,8))
    victory = @(@(0,0), @(0,-3), @(0,-5), @(0,-2))
  }
  $pair = $patterns[$AnimationName][$Index % $patterns[$AnimationName].Count]
  return @{ X = [int]$pair[0]; Y = [int]$pair[1] }
}

function Draw-Frame($Graphics, $SourceEntry, $FrameIndex, $SyntheticOffset) {
  $stream = $SourceEntry.Open()
  try {
    $source = [System.Drawing.Image]::FromStream($stream)
    try {
      $scale = [Math]::Min($FrameSize / $source.Width, $FrameSize / $source.Height)
      $width = [Math]::Max(1, [int][Math]::Round($source.Width * $scale))
      $height = [Math]::Max(1, [int][Math]::Round($source.Height * $scale))
      $x = ($FrameIndex * $FrameSize) + [int][Math]::Round(($FrameSize - $width) / 2) + $SyntheticOffset.X
      $y = [int][Math]::Round($FrameSize - $height) + $SyntheticOffset.Y
      $Graphics.DrawImage($source, $x, $y, $width, $height)
    }
    finally { $source.Dispose() }
  }
  finally { $stream.Dispose() }
}

function Write-Sheet($Archive, $FrameSource, $AnimationName, $OutputPath) {
  $sheet = New-Object System.Drawing.Bitmap ($FrameSize * $FrameCount), $FrameSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($sheet)
  try {
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    for ($index = 0; $index -lt $FrameCount; $index += 1) {
      if ($FrameSource.Synthetic) {
        $entry = $FrameSource.Entries[0]
        $offset = Get-SyntheticOffset $AnimationName $index
      } else {
        $entry = $FrameSource.Entries[[Math]::Min($index, $FrameSource.Entries.Count - 1)]
        $offset = @{ X = 0; Y = 0 }
      }
      Draw-Frame $graphics $entry $index $offset
    }
  }
  finally { $graphics.Dispose() }

  $sheet.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $sheet.Dispose()
}

function Get-AnimationManifest($Character, $Archive, $Folder, $AnimationName) {
  $animationMap = $Character.AnimationMap
  $candidates = if ($animationMap.ContainsKey($AnimationName)) { $animationMap[$AnimationName] } else { @() }
  $source = if ($candidates.Count -gt 0) { Get-AnimationFrames $Archive $Folder $candidates } else { $null }
  if (-not $source) { $source = Get-RotationFrame $Archive $Folder }
  return $source
}

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$ReceiptRows = @()

foreach ($character in $Characters) {
  $packet = Resolve-SourcePacket $character
  $archive = [System.IO.Compression.ZipFile]::OpenRead($packet.Path)
  try {
    $metadata = Read-Metadata $archive
    $folder = $character.Folder
    if ($metadata -and $metadata.states -and $metadata.states.Count -gt 0 -and $metadata.states[0].folder) {
      $folder = $metadata.states[0].folder
    }

    $characterDir = Join-Path $OutputRoot $character.Id
    New-Item -ItemType Directory -Force -Path $characterDir | Out-Null

    $animations = [ordered]@{}
    foreach ($animationName in @("idle", "walk", "run", "jump", "fall", "attack", "special", "hurt", "knockout", "victory")) {
      $frameSource = Get-AnimationManifest $character $archive $folder $animationName
      $fileName = "$animationName`_$FrameCount.png"
      $outputPath = Join-Path $characterDir $fileName
      Write-Sheet $archive $frameSource $animationName $outputPath
      $animations[$animationName] = [ordered]@{
        src = "assets/characters/prismcade-pixellab/$($character.Id)/$fileName"
        frames = $FrameCount
        frameWidth = $FrameSize
        frameHeight = $FrameSize
        fps = if ($LoopAnimations -contains $animationName) { 8 } else { 12 }
        loop = $LoopAnimations -contains $animationName
        source = $frameSource.Source
        synthetic = [bool]$frameSource.Synthetic
      }
    }

    $manifest = [ordered]@{
      schemaVersion = "pixel-fruit-arena-prismcade-character-v0"
      id = $character.Id
      displayName = $character.DisplayName
      sourceVariantId = $character.SourceVariantId
      sourceCharacterId = $character.SourceCharacterId
      sourceRegistry = "data/integrations/pixellab-character-export-registry.json"
      sourcePacketName = $packet.PacketName
      sourcePacketOrigin = $packet.Source
      sourceDownloadUrl = $character.DownloadUrl
      outputFrameSize = @{ width = $FrameSize; height = $FrameSize }
      animationFidelity = $character.AnimationFidelity
      animations = $animations
      notes = @(
        "Raw PixelLab export packets are not committed.",
        "These runtime sheets are normalized 64x64 game-facing outputs for Pixel Fruit Arena.",
        "Rotation-derived animations are playable placeholders and should be replaced by curated PixelLab animation jobs when available."
      )
    }

    $manifestPath = Join-Path $characterDir "manifest.json"
    Write-Utf8NoBom $manifestPath ($manifest | ConvertTo-Json -Depth 12)

    $ReceiptRows += "| $($character.DisplayName) | $($character.SourceVariantId) | $($packet.PacketName) | $($character.AnimationFidelity) | $($character.Id) |"
    Write-Output "Imported $($character.DisplayName) -> $characterDir"
  }
  finally { $archive.Dispose() }
}

$receipt = @"
# PixelLab Prismcade Roster Import Receipt

Generated by `games/pixel-fruit-arena/tools/import_pixellab_prismcade_roster.ps1`.

This folder contains normalized 64x64 runtime sheets made from Prismtek-owned PixelLab export packets. Raw PixelLab export zips are intentionally not committed.

| Character | Source variant | Source packet | Fidelity | Runtime id |
| --- | --- | --- | --- | --- |
$($ReceiptRows -join "`n")

OpenBOR, MUGEN, and Ikemen are not imported into this game runtime by this receipt. They remain engine/reference contracts until a reviewed adapter produces Prismtek-owned outputs with license receipts.
"@

Write-Utf8NoBom (Join-Path $OutputRoot "PROVENANCE.md") $receipt
Write-Output "PixelLab Prismcade roster import complete."
