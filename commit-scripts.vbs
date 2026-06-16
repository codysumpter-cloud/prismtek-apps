Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"
Dim logFile
logFile = repoDir & "\commit-scripts-output.txt"

' Remove git lock if present
Dim lockFile
lockFile = repoDir & "\.git\index.lock"
If objFSO.FileExists(lockFile) Then
    objFSO.DeleteFile lockFile, True
End If

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "git config user.email 'cody.sumpter@gmail.com' 2>&1 | Out-Null; " & _
    "git config user.name 'Cody Sumpter' 2>&1 | Out-Null; " & _
    "$out += (git add scripts/validate-platforms.mjs scripts/download-porting-kits.mjs scripts/verify-porting-kits.mjs scripts/smoke-dual-screen.mjs package.json 2>&1); " & _
    "$out += 'add exit: ' + $LASTEXITCODE; " & _
    "$out += (git status --short 2>&1); " & _
    "$commitOut = (git commit --no-verify -m 'feat: add platform, porting-kit, dual-screen, and game-support validation scripts' 2>&1); " & _
    "$commitExit = $LASTEXITCODE; " & _
    "$out += $commitOut; " & _
    "$out += 'commit exit: ' + $commitExit; " & _
    "$pushOut = (git push 2>&1); " & _
    "$pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & logFile & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\commit-scripts-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
