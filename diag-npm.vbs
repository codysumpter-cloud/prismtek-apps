Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += 'PATH:'; " & _
    "$out += $env:PATH -split ';' | Where-Object { $_ -match 'node|npm' }; " & _
    "$out += 'npm location:'; " & _
    "$out += (Get-Command npm -ErrorAction SilentlyContinue).Source; " & _
    "$out += 'node location:'; " & _
    "$out += (Get-Command node -ErrorAction SilentlyContinue).Source; " & _
    "$out += 'npm --version:'; " & _
    "$out += (npm --version 2>&1); " & _
    "$out += 'npm exit: ' + $LASTEXITCODE; " & _
    "$out += 'npm install test:'; " & _
    "$npmOut = (npm install 2>&1); " & _
    "$npmExit = $LASTEXITCODE; " & _
    "$out += $npmOut; " & _
    "$out += 'npm install exit: ' + $npmExit; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & repoDir & "\diag-npm-output.txt'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\diag-npm-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
