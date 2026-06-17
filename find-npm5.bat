<<<<<<< HEAD
@echo off
set OUT=C:\Users\cody_\prismtek-push\prismtek-apps\find-npm5-output.txt
echo === find-npm5 %date% %time% === > %OUT%
echo --- where /r C:\Users\cody_ npm.cmd --- >> %OUT%
where /r "C:\Users\cody_" npm.cmd >> %OUT% 2>&1
echo --- where /r C:\Users\cody_ node.exe --- >> %OUT%
where /r "C:\Users\cody_" node.exe >> %OUT% 2>&1
echo --- where /r C:\Program Files nodejs --- >> %OUT%
where /r "C:\Program Files" npm.cmd >> %OUT% 2>&1
echo done > C:\Users\cody_\prismtek-push\prismtek-apps\find-npm5-done.txt
=======
@echo off
set OUT=C:\Users\cody_\prismtek-push\prismtek-apps\find-npm5-output.txt
echo === find-npm5 %date% %time% === > %OUT%
echo --- where /r C:\Users\cody_ npm.cmd --- >> %OUT%
where /r "C:\Users\cody_" npm.cmd >> %OUT% 2>&1
echo --- where /r C:\Users\cody_ node.exe --- >> %OUT%
where /r "C:\Users\cody_" node.exe >> %OUT% 2>&1
echo --- where /r C:\Program Files nodejs --- >> %OUT%
where /r "C:\Program Files" npm.cmd >> %OUT% 2>&1
echo done > C:\Users\cody_\prismtek-push\prismtek-apps\find-npm5-done.txt
>>>>>>> 5e6ea9e (chore: update configuration files and workflows)
