@echo off
set NPM=C:\Users\cody_\AppData\Local\OpenAI\Codex\runtimes\cua_node\789504f803e82e2b\bin\npm.cmd
cd /d C:\Users\cody_\prismtek-push\prismtek-apps
echo === validate-all run %date% %time% === > validate-all-output.txt
echo --- npm install --- >> validate-all-output.txt
call "%NPM%" install >> validate-all-output.txt 2>&1
echo npm install exit: %errorlevel% >> validate-all-output.txt
echo --- npm run porting-kits:download --- >> validate-all-output.txt
call "%NPM%" run porting-kits:download >> validate-all-output.txt 2>&1
echo porting-kits:download exit: %errorlevel% >> validate-all-output.txt
echo --- npm run platforms:validate --- >> validate-all-output.txt
call "%NPM%" run platforms:validate >> validate-all-output.txt 2>&1
echo platforms:validate exit: %errorlevel% >> validate-all-output.txt
echo --- npm run porting-kits:verify --- >> validate-all-output.txt
call "%NPM%" run porting-kits:verify >> validate-all-output.txt 2>&1
echo porting-kits:verify exit: %errorlevel% >> validate-all-output.txt
echo --- npm run dual-screen:validate --- >> validate-all-output.txt
call "%NPM%" run dual-screen:validate >> validate-all-output.txt 2>&1
echo dual-screen:validate exit: %errorlevel% >> validate-all-output.txt
echo --- npm run dual-screen:smoke --- >> validate-all-output.txt
call "%NPM%" run dual-screen:smoke >> validate-all-output.txt 2>&1
echo dual-screen:smoke exit: %errorlevel% >> validate-all-output.txt
echo --- npm run games:validate-support --- >> validate-all-output.txt
call "%NPM%" run games:validate-support >> validate-all-output.txt 2>&1
echo games:validate-support exit: %errorlevel% >> validate-all-output.txt
echo === DONE %date% %time% === >> validate-all-output.txt
echo done > validate-batch-done.txt
