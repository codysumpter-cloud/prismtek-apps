Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "Set-Location '" & repoDir & "'; " & _
    "$out = @(); " & _
    "$out += '=== START ' + (Get-Date); " & _
    "$out += '--- Full Process PATH ---'; " & _
    "$out += $env:PATH -split ';'; " & _
    "$out += '--- NVM check ---'; " & _
    "$out += (Get-ChildItem $env:APPDATA\nvm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName); " & _
    "$out += (Get-ChildItem $env:LOCALAPPDATA\nvm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName); " & _
    "$out += '--- Program Files nodejs ---'; " & _
    "$out += (Test-Path 'C:\Program Files\nodejs\npm.cmd').ToString(); " & _
    "$out += '--- AppData Local nvs ---'; " & _
    "$out += (Test-Path ($env:LOCALAPPDATA + '\nvs')).ToString(); " & _
    "$out += '--- Find npm.cmd anywhere in common dirs ---'; " & _
    "$dirs = @('C:\Program Files\nodejs','C:\Program Files (x86)\nodejs'," & _
    "  ($env:APPDATA+'\npm'),($env:APPDATA+'\nvm'),($env:LOCALAPPDATA+'\nvs')," & _
    "  'C:\ProgramData\chocolatey\bin','C:\tools\nodejs'); " & _
    "foreach ($d in $dirs) { if (Test-Path ($d+'\npm.cmd')) { $out += 'FOUND npm.cmd at: '+$d } }; " & _
    "$out += '=== END ' + (Get-Date); " & _
    "$out | Out-File '" & repoDir & "\find-npm2-output.txt'" & Chr(34)

objShell.Run cmd, 0, True

Set f = objFSO.CreateTextFile(repoDir & "\find-npm2-done.txt", True)
f.WriteLine "Done at: " & Now()
f.Close
