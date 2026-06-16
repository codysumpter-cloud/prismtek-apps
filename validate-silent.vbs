Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$log = '" & repoDir & "\validate-all-output.txt'; " & _
    "$results = @(); " & _
    "'=== validate-all run ' + (Get-Date) | Out-File $log; " & _
    "function Run-Step { " & _
    "  param([string]$Label, [string[]]$CmdArgs) " & _
    "  $o = (& $CmdArgs[0] $CmdArgs[1..($CmdArgs.Length-1)] 2>&1); " & _
    "  $e = $LASTEXITCODE; " & _
    "  $s = if ($e -eq 0) { 'PASS' } else { 'FAIL (exit ' + $e + ')' }; " & _
    "  $o | Out-File -Append $log; " & _
    "  ('=== ' + $Label + ' : ' + $s + ' ===') | Out-File -Append $log; " & _
    "  $script:results += [pscustomobject]@{ Command=$Label; Status=$s; ExitCode=$e } " & _
    "}; " & _
    "Run-Step 'npm install' @('npm','install'); " & _
    "Run-Step 'npm run porting-kits:download' @('npm','run','porting-kits:download'); " & _
    "Run-Step 'npm run platforms:validate' @('npm','run','platforms:validate'); " & _
    "Run-Step 'npm run porting-kits:verify' @('npm','run','porting-kits:verify'); " & _
    "Run-Step 'npm run dual-screen:validate' @('npm','run','dual-screen:validate'); " & _
    "Run-Step 'npm run dual-screen:smoke' @('npm','run','dual-screen:smoke'); " & _
    "Run-Step 'npm run games:validate-support' @('npm','run','games:validate-support'); " & _
    "'=== SUMMARY ===' | Out-File -Append $log; " & _
    "$results | ForEach-Object { ('{0,-40} {1}' -f $_.Command,$_.Status) | Out-File -Append $log }; " & _
    "$p = ($results | Where-Object { $_.Status -like 'PASS*' }).Count; " & _
    "$f = ($results | Where-Object { $_.Status -notlike 'PASS*' }).Count; " & _
    "('TOTAL: ' + $p + ' passed, ' + $f + ' failed') | Out-File -Append $log; " & _
    "'=== DONE ' + (Get-Date) | Out-File -Append $log" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\validate-silent-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
