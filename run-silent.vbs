Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""C:\Users\cody_\prismtek-push\prismtek-apps\nuke-and-commit.ps1""", 0, False
WScript.Quit
