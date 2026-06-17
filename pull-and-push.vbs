<<<<<<< HEAD
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\pull-push-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- git pull --rebase ---'; " & _
    "$out += (git pull --rebase 2>&1); " & _
    "$out += 'pull exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "} else { " & _
    "  $out += 'pull failed, skipping push' " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\pull-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
=======
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\pull-push-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- git pull --rebase ---'; " & _
    "$out += (git pull --rebase 2>&1); " & _
    "$out += 'pull exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "} else { " & _
    "  $out += 'pull failed, skipping push' " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\pull-push-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
