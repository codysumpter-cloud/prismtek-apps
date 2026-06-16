Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim log
log = "C:\Users\cody_\prismtek-push\prismtek-apps\rebase-continue-output.txt"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location 'C:\Users\cody_\prismtek-push\prismtek-apps'; " & _
    "$env:GIT_AUTHOR_NAME = 'Cody Sumpter'; " & _
    "$env:GIT_AUTHOR_EMAIL = 'cody.sumpter@gmail.com'; " & _
    "$env:GIT_COMMITTER_NAME = 'Cody Sumpter'; " & _
    "$env:GIT_COMMITTER_EMAIL = 'cody.sumpter@gmail.com'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- git config identity ---'; " & _
    "$out += (git config user.email 'cody.sumpter@gmail.com' 2>&1); " & _
    "$out += (git config user.name 'Cody Sumpter' 2>&1); " & _
    "$out += '--- git rebase --continue ---'; " & _
    "$out += (git rebase --continue 2>&1); " & _
    "$out += 'rebase exit: ' + $LASTEXITCODE; " & _
    "if ($LASTEXITCODE -eq 0) { " & _
    "  $out += '--- git push ---'; " & _
    "  $out += (git push 2>&1); " & _
    "  $out += 'push exit: ' + $LASTEXITCODE " & _
    "} else { " & _
    "  $out += 'rebase failed'; " & _
    "  $out += (git status 2>&1) " & _
    "}; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & log & "'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\rebase-continue-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
