$ErrorActionPreference = 'Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '../..')
$Node = Join-Path $Root '.prismtek-tools/bin/node.cmd'
if (-not (Test-Path $Node)) {
  & (Join-Path $Root 'tools/bootstrap/bootstrap-node.ps1')
}
& $Node (Join-Path $Root 'tools/bootstrap/toolchain.mjs') @args
exit $LASTEXITCODE
