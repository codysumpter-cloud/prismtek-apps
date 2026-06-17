Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Write a marker file so we know VBS executed
Set f = objFSO.CreateTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\diag-ran.txt", True)
f.WriteLine "VBS ran at: " & Now()
f.Close

' Run PowerShell to log process list and try operations, output to log file
Dim cmd
cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -Command " & Chr(34) & _
    "$log = 'C:\Users\cody_\prismtek-push\prismtek-apps\diag-output.txt'; " & _
    "'=== DIAG RUN ' + (Get-Date) | Out-File $log; " & _
    "'--- git processes ---' | Out-File -Append $log; " & _
    "(Get-Process git,npm,node -ErrorAction SilentlyContinue | Select-Object Name,Id,CPU | Out-String) | Out-File -Append $log; " & _
    "'--- taskkill git ---' | Out-File -Append $log; " & _
    "(& taskkill /F /T /IM git.exe 2>&1) | Out-File -Append $log; " & _
    "Start-Sleep 2; " & _
    "'--- lock check ---' | Out-File -Append $log; " & _
    "(Test-Path 'C:\Users\cody_\prismtek-push\prismtek-apps\.git\index.lock') | Out-File -Append $log; " & _
    "'--- remove lock ---' | Out-File -Append $log; " & _
    "try { Remove-Item 'C:\Users\cody_\prismtek-push\prismtek-apps\.git\index.lock' -Force -EA Stop; 'removed ok' | Out-File -Append $log } catch { $_.Exception.Message | Out-File -Append $log }; " & _
    "'--- done ---' | Out-File -Append $log" & Chr(34)

objShell.Run cmd, 0, True

' Update marker
Set f = objFSO.OpenTextFile("C:\Users\cody_\prismtek-push\prismtek-apps\diag-ran.txt", 8)
f.WriteLine "VBS finished at: " & Now()
f.Close
