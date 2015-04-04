@echo off
del legendsfx.prg
set KICKASS_PATH="bin\Kickass.jar"
call java -jar %KICKASS_PATH% main.asm -o legend.prg -afo
call bin\exomizer.exe sfx $0440 legend.prg -o legendsfx.prg -Di_table_addr=0x02  -Di_line_number=2015 -s "sei lda #$00 sta $d011 sta $d020" -n
del *.sym
del legend.prg
pause
