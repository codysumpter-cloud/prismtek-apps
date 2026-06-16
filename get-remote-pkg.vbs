Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"
Dim logFile
logFile = repoDir & "\get-remote-pkg-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += (git show origin/main:package.json 2>&1); " & _
    "$out += '=== EXIT ' + $LASTEXITCODE; " & _
    "$out += '=== LOG'; " & _
    "$out += (git log --oneline origin/main -5 2>&1); " & _
    "$out += '=== STATUS'; " & _
    "$out += (git status --short 2>&1); " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & logFile & "' -Encoding UTF8" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\get-remote-pkg-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
