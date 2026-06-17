<<<<<<< HEAD
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"
Dim logFile
logFile = repoDir & "\stash-pull-push-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git status --short 2>&1); " & _
    "$stashOut = (git stash 2>&1); $stashExit = $LASTEXITCODE; " & _
    "$out += 'stash: ' + $stashOut + ' (exit ' + $stashExit + ')'; " & _
    "$pullOut = (git pull --rebase 2>&1); $pullExit = $LASTEXITCODE; " & _
    "$out += $pullOut; " & _
    "$out += 'pull exit: ' + $pullExit; " & _
    "if ($stashExit -eq 0 -and $stashOut -notmatch 'No local changes') { " & _
    "  $popOut = (git stash pop 2>&1); " & _
    "  $out += 'stash pop: ' + $popOut; " & _
    "}; " & _
    "$pushOut = (git push 2>&1); $pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += (git log --oneline -4 2>&1); " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & logFile & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\stash-pull-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
=======
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"
Dim logFile
logFile = repoDir & "\stash-pull-push-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git status --short 2>&1); " & _
    "$stashOut = (git stash 2>&1); $stashExit = $LASTEXITCODE; " & _
    "$out += 'stash: ' + $stashOut + ' (exit ' + $stashExit + ')'; " & _
    "$pullOut = (git pull --rebase 2>&1); $pullExit = $LASTEXITCODE; " & _
    "$out += $pullOut; " & _
    "$out += 'pull exit: ' + $pullExit; " & _
    "if ($stashExit -eq 0 -and $stashOut -notmatch 'No local changes') { " & _
    "  $popOut = (git stash pop 2>&1); " & _
    "  $out += 'stash pop: ' + $popOut; " & _
    "}; " & _
    "$pushOut = (git push 2>&1); $pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += (git log --oneline -4 2>&1); " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & logFile & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\stash-pull-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
