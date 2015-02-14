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
		
		// <FRESHNESS>
		.const	videomode	=	$80	
		.const	CIAtype		=	$81
		jsr CopyData	// Test purpose
		jsr DetectCIA
		jsr DetectVIC
		jsr start_timer
		jsr	initscroll
		// </FRESHNESS>
				
		:d011($3b)
		:d012($f9)
		:set_irq(msx_irq)

		cli

	test:				// Main with misc jittering
		nop
		bit $02
		bit.a $0002
		inc $02
		inc.a $0002		
		jmp test

msx_irq:
		:open_irq()
		lda #BLACK
		sta $d021
		asl $d019
		lda #$10
		sta $d011
		inc $d020
		jsr music.play
		dec $d020

		jsr set_mdlirq	// Freshness
		:close_irq()
		rti

.pc = * "functions"
.import source "functions.asm"

.pc = $900 "logo_swinger"
//<FRESHNESS>
.import source "top_sprite_routine.asm"
.import source "timer.asm"
.import source "detect.asm"
//</FRESHNESS>

.pc = $2600 "screendata"
screendata:
.import binary "data/screen.raw"

.pc = $2a00 "pixels"
.import binary "data/pixels.raw"

.pc = $3700
.import binary "sprites.prg"	// Fresh

//.pc = $4000
.fill $4000,256*random()

.pc = $8000 "colour ram"
.import binary "data/d800.raw"
