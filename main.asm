.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

:BasicUpstart2(code)

.pc = $810 "code"
code:
		sei
		.if(PLAY_MUSIC){
			lda #0
			jsr music.init
		}
		:d011(0)
		:kernal_off()
		:turn_off_cia_turn_on_raster_irq()
		:kill_nmi()

		lda #border_colour
		sta $d020

		lda #screen_colour
		sta $d021

		:bank_0()

		lda #$d8
		sta $d016

		lda #$18
		sta $d018

		jsr copy_screendata

		lda #0
		sta $d015

		:wait_frame()
		
		:d011($3b)
		:d012($f9)
		:set_irq(msx_irq)

		cli

		jmp *

msx_irq:
		:open_irq()
		asl $d019

		inc $d020
		jsr music.play
		dec $d020

		:close_irq()
		rti

.pc = $900 "logo_swinger"
.import source "top_sprite_routine.asm"

.pc = $2000
screendata:
.import binary "data/screen.raw"

.pc = * "functions"
.import source "functions.asm"

.pc = $2a00
.import binary "data/pixels.raw"

.pc = $d800
.import binary "data/d800.raw"
