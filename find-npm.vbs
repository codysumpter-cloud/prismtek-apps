Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- Machine PATH segments ---'; " & _
    "$mp = [Environment]::GetEnvironmentVariable('PATH','Machine') -split ';'; " & _
    "$out += $mp | Where-Object { $_ -match 'node|npm' }; " & _
    "$out += '--- User PATH segments ---'; " & _
    "$up = [Environment]::GetEnvironmentVariable('PATH','User') -split ';'; " & _
    "$out += $up | Where-Object { $_ -match 'node|npm|nvm' }; " & _
    "$out += '--- All User PATH ---'; " & _
    "$out += $up; " & _
    "$out += '--- Search common npm locations ---'; " & _
    "$candidates = @(" & _
    "  'C:\Program Files\nodejs\npm.cmd'," & _
    "  'C:\Program Files (x86)\nodejs\npm.cmd'," & _
    "  ($env:APPDATA + '\npm\npm.cmd')," & _
    "  ($env:APPDATA + '\nvm\npm.cmd')," & _
    "  ($env:LOCALAPPDATA + '\nvs\npm.cmd')" & _
    "); " & _
    "foreach ($c in $candidates) { if (Test-Path $c) { $out += 'FOUND: ' + $c } }; " & _
    "$out += '--- where.exe npm ---'; " & _
    "$out += (where.exe npm 2>&1); " & _
    "$out += '--- where.exe node ---'; " & _
    "$out += (where.exe node 2>&1); " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & repoDir & "\find-npm-output.txt'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\find-npm-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
