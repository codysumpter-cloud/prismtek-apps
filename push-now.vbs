<<<<<<< HEAD
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\push-now-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$env:GIT_AUTHOR_NAME = 'Cody Sumpter'; " & _
    "$env:GIT_AUTHOR_EMAIL = 'cody.sumpter@gmail.com'; " & _
    "$env:GIT_COMMITTER_NAME = 'Cody Sumpter'; " & _
    "$env:GIT_COMMITTER_EMAIL = 'cody.sumpter@gmail.com'; " & _
    "git config user.email 'cody.sumpter@gmail.com' 2>&1 | Out-Null; " & _
    "git config user.name 'Cody Sumpter' 2>&1 | Out-Null; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git log --oneline -3 2>&1); " & _
    "$out += '--- git push ---'; " & _
    "$out += (git push 2>&1); " & _
    "$pushExit = $LASTEXITCODE; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\push-now-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
=======
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\push-now-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$env:GIT_AUTHOR_NAME = 'Cody Sumpter'; " & _
    "$env:GIT_AUTHOR_EMAIL = 'cody.sumpter@gmail.com'; " & _
    "$env:GIT_COMMITTER_NAME = 'Cody Sumpter'; " & _
    "$env:GIT_COMMITTER_EMAIL = 'cody.sumpter@gmail.com'; " & _
    "git config user.email 'cody.sumpter@gmail.com' 2>&1 | Out-Null; " & _
    "git config user.name 'Cody Sumpter' 2>&1 | Out-Null; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git log --oneline -3 2>&1); " & _
    "$out += '--- git push ---'; " & _
    "$out += (git push 2>&1); " & _
    "$pushExit = $LASTEXITCODE; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\push-now-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
