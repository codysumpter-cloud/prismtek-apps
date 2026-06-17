@echo off
set OUT=C:\Users\cody_\prismtek-push\prismtek-apps\find-npm3-output.txt
echo === find-npm3 %date% %time% === > %OUT%
echo --- where npm --- >> %OUT%
where npm >> %OUT% 2>&1
echo --- where node --- >> %OUT%
where node >> %OUT% 2>&1
echo --- WindowsApps npm* --- >> %OUT%
dir "C:\Users\cody_\AppData\Local\Microsoft\WindowsApps\npm*" /b >> %OUT% 2>&1
echo --- WindowsApps node* --- >> %OUT%
dir "C:\Users\cody_\AppData\Local\Microsoft\WindowsApps\node*" /b >> %OUT% 2>&1
echo --- fnm check --- >> %OUT%
dir "C:\Users\cody_\AppData\Local\fnm" /b >> %OUT% 2>&1
echo --- volta check --- >> %OUT%
dir "C:\Users\cody_\AppData\Local\Volta\bin" /b >> %OUT% 2>&1
echo --- nvm-windows check --- >> %OUT%
dir "C:\Users\cody_\AppData\Local\nvm" /b >> %OUT% 2>&1
echo --- AppData\Local\Programs npm* --- >> %OUT%
dir "C:\Users\cody_\AppData\Local\Programs" /b >> %OUT% 2>&1
echo --- FULL PATH --- >> %OUT%
echo %PATH% >> %OUT%
echo --- DONE --- >> %OUT%
echo done > C:\Users\cody_\prismtek-push\prismtek-apps\find-npm3-done.txt
