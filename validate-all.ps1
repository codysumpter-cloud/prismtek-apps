<<<<<<< HEAD
# validate-all.ps1
# Runs: npm install, then the requested validation scripts.
# Captures pass/fail per command and writes a summary log.

$ErrorActionPreference = "Continue"
$REPO = "C:\Users\cody_\prismtek-push\prismtek-apps"
Set-Location $REPO

$LOG = "$REPO\validate-all-output.txt"
$results = @()

function Run-Step {
    param([string]$Label, [string]$Cmd, [string[]]$Args)
    Write-Host ""
    Write-Host ">>> $Label" -ForegroundColor Cyan
    $output = & $Cmd @Args 2>&1
    $exit = $LASTEXITCODE
    $status = if ($exit -eq 0) { "PASS" } else { "FAIL (exit $exit)" }
    $color  = if ($exit -eq 0) { "Green" } else { "Red" }
    Write-Host $output
    Write-Host "--- $Label: $status ---" -ForegroundColor $color
    $script:results += [pscustomobject]@{ Command = $Label; Status = $status; ExitCode = $exit }
    $output | Out-File -Append -FilePath $LOG
    "=== $Label : $status ===" | Out-File -Append -FilePath $LOG
}

"=== validate-all run $(Get-Date) ===" | Out-File -FilePath $LOG

# 1. npm install
Run-Step "npm install" "npm" @("install")

# 2-7. Validation scripts
$scripts = @(
    "porting-kits:download",
    "platforms:validate",
    "porting-kits:verify",
    "dual-screen:validate",
    "dual-screen:smoke",
    "games:validate-support"
)

foreach ($s in $scripts) {
    Run-Step "npm run $s" "npm" @("run", $s)
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor White
Write-Host "  SUMMARY" -ForegroundColor White
Write-Host "============================================" -ForegroundColor White
$results | ForEach-Object {
    $color = if ($_.Status -like "PASS*") { "Green" } else { "Red" }
    Write-Host ("  {0,-35} {1}" -f $_.Command, $_.Status) -ForegroundColor $color
}

$passCount = ($results | Where-Object { $_.Status -like "PASS*" }).Count
$failCount = ($results | Where-Object { $_.Status -notlike "PASS*" }).Count
Write-Host ""
Write-Host "  $passCount passed, $failCount failed" -ForegroundColor White

# Write summary to log
"`n=== SUMMARY ===" | Out-File -Append -FilePath $LOG
$results | ForEach-Object { ("{0,-35} {1}" -f $_.Command, $_.Status) | Out-File -Append -FilePath $LOG }

Write-Host ""
Write-Host "Full output saved to: $LOG" -ForegroundColor Gray
Write-Host "Press any key to close." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
=======
# validate-all.ps1
# Runs: npm install, then the requested validation scripts.
# Captures pass/fail per command and writes a summary log.

$ErrorActionPreference = "Continue"
$REPO = "C:\Users\cody_\prismtek-push\prismtek-apps"
Set-Location $REPO

$LOG = "$REPO\validate-all-output.txt"
$results = @()

function Run-Step {
    param([string]$Label, [string]$Cmd, [string[]]$Args)
    Write-Host ""
    Write-Host ">>> $Label" -ForegroundColor Cyan
    $output = & $Cmd @Args 2>&1
    $exit = $LASTEXITCODE
    $status = if ($exit -eq 0) { "PASS" } else { "FAIL (exit $exit)" }
    $color  = if ($exit -eq 0) { "Green" } else { "Red" }
    Write-Host $output
    Write-Host "--- $Label: $status ---" -ForegroundColor $color
    $script:results += [pscustomobject]@{ Command = $Label; Status = $status; ExitCode = $exit }
    $output | Out-File -Append -FilePath $LOG
    "=== $Label : $status ===" | Out-File -Append -FilePath $LOG
}

"=== validate-all run $(Get-Date) ===" | Out-File -FilePath $LOG

# 1. npm install
Run-Step "npm install" "npm" @("install")

# 2-7. Validation scripts
$scripts = @(
    "porting-kits:download",
    "platforms:validate",
    "porting-kits:verify",
    "dual-screen:validate",
    "dual-screen:smoke",
    "games:validate-support"
)

foreach ($s in $scripts) {
    Run-Step "npm run $s" "npm" @("run", $s)
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor White
Write-Host "  SUMMARY" -ForegroundColor White
Write-Host "============================================" -ForegroundColor White
$results | ForEach-Object {
    $color = if ($_.Status -like "PASS*") { "Green" } else { "Red" }
    Write-Host ("  {0,-35} {1}" -f $_.Command, $_.Status) -ForegroundColor $color
}

$passCount = ($results | Where-Object { $_.Status -like "PASS*" }).Count
$failCount = ($results | Where-Object { $_.Status -notlike "PASS*" }).Count
Write-Host ""
Write-Host "  $passCount passed, $failCount failed" -ForegroundColor White

# Write summary to log
"`n=== SUMMARY ===" | Out-File -Append -FilePath $LOG
$results | ForEach-Object { ("{0,-35} {1}" -f $_.Command, $_.Status) | Out-File -Append -FilePath $LOG }

Write-Host ""
Write-Host "Full output saved to: $LOG" -ForegroundColor Gray
Write-Host "Press any key to close." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
