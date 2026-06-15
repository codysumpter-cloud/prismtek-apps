$ErrorActionPreference = 'Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '../..')
& (Join-Path $Root 'tools/bootstrap/bootstrap-node.ps1')
& (Join-Path $Root 'tools/bootstrap/npm.ps1') install
& (Join-Path $Root 'tools/bootstrap/npm.ps1') run platforms:validate
& (Join-Path $Root 'tools/bootstrap/npm.ps1') run games:validate-support
