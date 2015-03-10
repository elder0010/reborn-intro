@echo off
set KICKASS_PATH="bin\Kickass.jar"
call java -jar %KICKASS_PATH% main.asm -o legend.prg -afo
call bin\exomizer.exe sfx $810 legend.prg -o legendsfx.prg
