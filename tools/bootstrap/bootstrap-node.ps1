$ErrorActionPreference = 'Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '../..')
$Version = (Get-Content (Join-Path $Root 'tools/bootstrap/node-version.txt') -Raw).Trim()
$ToolsDir = Join-Path $Root '.prismtek-tools'
$NodeHome = Join-Path $ToolsDir "node-v$Version"
$BinDir = Join-Path $ToolsDir 'bin'
$Arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { 'x64' }
$Archive = "node-v$Version-win-$Arch.zip"
$Url = "https://nodejs.org/dist/v$Version/$Archive"
$ZipPath = Join-Path $ToolsDir $Archive

New-Item -ItemType Directory -Force -Path $ToolsDir, $BinDir | Out-Null

if (-not (Test-Path (Join-Path $NodeHome 'node.exe'))) {
  Write-Host "Downloading Node.js v$Version for win-$Arch..."
  Invoke-WebRequest -Uri $Url -OutFile $ZipPath
  $ExtractDir = Join-Path $ToolsDir "node-v$Version-win-$Arch"
  Remove-Item -Recurse -Force $NodeHome, $ExtractDir -ErrorAction SilentlyContinue
  Expand-Archive -Path $ZipPath -DestinationPath $ToolsDir -Force
  Move-Item -Path $ExtractDir -Destination $NodeHome
  Remove-Item -Force $ZipPath
}

@"
@echo off
"$NodeHome\node.exe" %*
"@ | Set-Content -Encoding ASCII (Join-Path $BinDir 'node.cmd')

@"
@echo off
"$NodeHome\npm.cmd" %*
"@ | Set-Content -Encoding ASCII (Join-Path $BinDir 'npm.cmd')

@"
@echo off
"$NodeHome\npx.cmd" %*
"@ | Set-Content -Encoding ASCII (Join-Path $BinDir 'npx.cmd')

& (Join-Path $BinDir 'node.cmd') -v
& (Join-Path $BinDir 'npm.cmd') -v
Write-Host 'Repo-local Node is ready.'
Write-Host 'Use: pwsh tools/bootstrap/npm.ps1 install'
