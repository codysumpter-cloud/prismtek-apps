<<<<<<< HEAD
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\do-commit-output.txt"

' Run git commit --no-verify then git push, capture all output
Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- git status ---'; " & _
    "$out += (git status --short 2>&1); " & _
    "$out += '--- git commit --no-verify ---'; " & _
    "$out += (git -c user.email='cody.sumpter@gmail.com' -c user.name='Cody Sumpter' commit --no-verify -m 'refile: move character sprites from misc/ to characters/' 2>&1); " & _
    "$out += 'commit exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

' Signal completion
Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\do-commit-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
=======
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\do-commit-output.txt"

' Run git commit --no-verify then git push, capture all output
Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- git status ---'; " & _
    "$out += (git status --short 2>&1); " & _
    "$out += '--- git commit --no-verify ---'; " & _
    "$out += (git -c user.email='cody.sumpter@gmail.com' -c user.name='Cody Sumpter' commit --no-verify -m 'refile: move character sprites from misc/ to characters/' 2>&1); " & _
    "$out += 'commit exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

' Signal completion
Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\do-commit-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
