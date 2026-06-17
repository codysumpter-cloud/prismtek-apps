<<<<<<< HEAD
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\pull-push2-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- set identity ---'; " & _
    "$out += (git config user.email 'cody.sumpter@gmail.com' 2>&1); " & _
    "$out += (git config user.name 'Cody Sumpter' 2>&1); " & _
    "$out += '--- git pull --rebase ---'; " & _
    "$out += (git pull --rebase 2>&1); " & _
    "$out += 'pull exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "} else { " & _
    "  $out += 'pull failed'; " & _
    "  $out += (git status 2>&1) " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\pull-push2-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
=======
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\pull-push2-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- set identity ---'; " & _
    "$out += (git config user.email 'cody.sumpter@gmail.com' 2>&1); " & _
    "$out += (git config user.name 'Cody Sumpter' 2>&1); " & _
    "$out += '--- git pull --rebase ---'; " & _
    "$out += (git pull --rebase 2>&1); " & _
    "$out += 'pull exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "} else { " & _
    "  $out += 'pull failed'; " & _
    "  $out += (git status 2>&1) " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\pull-push2-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
