<<<<<<< HEAD
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "git config user.email 'cody.sumpter@gmail.com' 2>&1 | Out-Null; " & _
    "git config user.name 'Cody Sumpter' 2>&1 | Out-Null; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git log --oneline -3 2>&1); " & _
    "$out += '--- git push ---'; " & _
    "$pushOut = (git push 2>&1); " & _
    "$pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & repoDir & "\git-push-output.txt'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\git-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
=======
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "git config user.email 'cody.sumpter@gmail.com' 2>&1 | Out-Null; " & _
    "git config user.name 'Cody Sumpter' 2>&1 | Out-Null; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git log --oneline -3 2>&1); " & _
    "$out += '--- git push ---'; " & _
    "$pushOut = (git push 2>&1); " & _
    "$pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & repoDir & "\git-push-output.txt'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\git-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
