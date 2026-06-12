param(
  [Parameter(Mandatory=$true)][string]$SpriteManifest
)

$data = Get-Content -Raw -LiteralPath $SpriteManifest | ConvertFrom-Json
$required = @("idle","walk","run","jump","fall","attack","special","hurt","knockout","victory")
$errors = New-Object System.Collections.Generic.List[string]

if ($data.sprite_width -ne 64 -or $data.sprite_height -ne 64) {
  $errors.Add("sprite size must be 64x64")
}

$names = @($data.animations | ForEach-Object { $_.name })
foreach ($name in $required) {
  if ($names -notcontains $name) { $errors.Add("missing animation: $name") }
}

foreach ($animation in $data.animations) {
  if ($animation.frames -lt 1) { $errors.Add("$($animation.name) has no frames") }
  if ($animation.fps -le 0) { $errors.Add("$($animation.name) fps must be positive") }
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Output "Validated $SpriteManifest`: $($names.Count) animations, 64x64"
