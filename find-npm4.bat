<<<<<<< HEAD
@echo off
set OUT=C:\Users\cody_\prismtek-push\prismtek-apps\find-npm4-output.txt
echo === find-npm4 %date% %time% === > %OUT%
echo --- scoop check --- >> %OUT%
dir "C:\Users\cody_\scoop\shims\npm*" /b >> %OUT% 2>&1
echo --- chocolatey check --- >> %OUT%
dir "C:\ProgramData\chocolatey\bin\npm*" /b >> %OUT% 2>&1
echo --- WSL npm check disabled --- >> %OUT%
echo skipped WSL npm probe because WSL is not used on this machine >> %OUT% 2>&1
echo --- PS profile load + npm --- >> %OUT%
powershell -NoLogo -ExecutionPolicy Bypass -Command "try { . $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 } catch {}; try { . $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 } catch {}; 'npm location: ' + (Get-Command npm -EA SilentlyContinue).Source; 'PATH after profile: ' + $env:PATH" >> %OUT% 2>&1
echo done > C:\Users\cody_\prismtek-push\prismtek-apps\find-npm4-done.txt
=======
@echo off
set OUT=C:\Users\cody_\prismtek-push\prismtek-apps\find-npm4-output.txt
echo === find-npm4 %date% %time% === > %OUT%
echo --- scoop check --- >> %OUT%
dir "C:\Users\cody_\scoop\shims\npm*" /b >> %OUT% 2>&1
echo --- chocolatey check --- >> %OUT%
dir "C:\ProgramData\chocolatey\bin\npm*" /b >> %OUT% 2>&1
echo --- WSL npm check disabled --- >> %OUT%
echo skipped WSL npm probe because WSL is not used on this machine >> %OUT% 2>&1
echo --- PS profile load + npm --- >> %OUT%
powershell -NoLogo -ExecutionPolicy Bypass -Command "try { . $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 } catch {}; try { . $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 } catch {}; 'npm location: ' + (Get-Command npm -EA SilentlyContinue).Source; 'PATH after profile: ' + $env:PATH" >> %OUT% 2>&1
echo done > C:\Users\cody_\prismtek-push\prismtek-apps\find-npm4-done.txt
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
