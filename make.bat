@echo off
del legendsfx.prg
set KICKASS_PATH="bin\Kickass.jar"
call java -jar %KICKASS_PATH% src\main.asm -o legend_unpacked.prg -afo :gamestart=2061 :linkgame=1 :filename="resources\spires.prg"
call bin\exomizer.exe sfx $0440 legend_unpacked.prg -o legend_intro.prg -Di_table_addr=0x02  -Di_line_number=2015 -s "sei lda #$00 sta $d011 sta $d020" -n
del src\*.sym
del legend_unpacked.prg
pause
