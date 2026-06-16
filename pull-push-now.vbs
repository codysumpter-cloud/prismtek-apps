Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"
Dim logFile
logFile = repoDir & "\pull-push-now-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$pullOut = (git pull --rebase 2>&1); " & _
    "$pullExit = $LASTEXITCODE; " & _
    "$out += $pullOut; " & _
    "$out += 'pull exit: ' + $pullExit; " & _
    "$pushOut = (git push 2>&1); " & _
    "$pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += (git log --oneline -3 2>&1); " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & logFile & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\pull-push-now-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
