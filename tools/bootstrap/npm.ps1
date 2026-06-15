$ErrorActionPreference = 'Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '../..')
$Npm = Join-Path $Root '.prismtek-tools/bin/npm.cmd'
if (-not (Test-Path $Npm)) {
  & (Join-Path $Root 'tools/bootstrap/bootstrap-node.ps1')
}
$env:PATH = "$(Join-Path $Root '.prismtek-tools/bin');$env:PATH"
& $Npm @args
exit $LASTEXITCODE
