$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
Set-Location $repoRoot

if (-not (Test-Path "node_modules")) {
  Write-Host "Installing Prismtek app workspace dependencies..."
  npm ci
}

if (-not $env:BEMORE_GEMMA4_MODEL) {
  $env:BEMORE_GEMMA4_MODEL = "gemma4"
}

if (-not $env:BEMORE_GEMMA4_API_BASE_URL) {
  $env:BEMORE_GEMMA4_API_BASE_URL = "http://127.0.0.1:11434/v1"
}

Write-Host "Starting BeMore Buddy Gemma 4 gateway on http://127.0.0.1:4320"
Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd '$repoRoot'; `$env:BEMORE_GEMMA4_MODEL='$($env:BEMORE_GEMMA4_MODEL)'; `$env:BEMORE_GEMMA4_API_BASE_URL='$($env:BEMORE_GEMMA4_API_BASE_URL)'; npm --workspace apps/bemore-macos run dev:gemma4"
)

Write-Host "Starting BeMore Buddy desktop shell on http://127.0.0.1:4319"
Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd '$repoRoot'; npm --workspace apps/bemore-macos run dev:windows"
)

Start-Sleep -Seconds 3
Start-Process "http://127.0.0.1:4319"

Write-Host "BeMore Buddy Windows shell launched. Keep both PowerShell windows open while using the app."
