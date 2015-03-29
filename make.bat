@echo off
del legendsfx.prg
set KICKASS_PATH="bin\Kickass.jar"
call java -jar %KICKASS_PATH% main.asm -o legend.prg -afo
call bin\exomizer.exe sfx $0440 legend.prg -o legendsfx.prg
del *.sym
del legend.prg
pause
