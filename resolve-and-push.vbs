Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"
Dim logFile
logFile = repoDir & "\resolve-and-push-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$env:GIT_EDITOR = 'true'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git add package.json 2>&1); " & _
    "$out += 'add exit: ' + $LASTEXITCODE; " & _
    "$out += (git status --short 2>&1); " & _
    "$continueOut = (git rebase --continue 2>&1); $continueExit = $LASTEXITCODE; " & _
    "$out += $continueOut; " & _
    "$out += 'rebase-continue exit: ' + $continueExit; " & _
    "$pushOut = (git push 2>&1); $pushExit = $LASTEXITCODE; " & _
    "$out += $pushOut; " & _
    "$out += 'push exit: ' + $pushExit; " & _
    "$out += (git log --oneline -5 2>&1); " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & logFile & "' -Encoding UTF8" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\resolve-and-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
