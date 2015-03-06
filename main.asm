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

		:d011($00)		// Freshness
		jsr initscroll	// Freshness
		
		:wait_frame()
				
		jsr start_timer	// Freshness		
				
		:d011($3b)
		:d012($f9)
		:set_irq(msx_irq)

		cli

	test:				// Main with misc jittering
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

.pc = * "logo_swinger"
//<FRESHNESS>
.import source "top_sprite_routine.asm"
.import source "timer.asm"
.pc=* "End of code"
.align $0100
logo:
.fill	$200,random()*256

.pc = $2000 "Top sprites"
b0sprite:
.import binary "sprites.prg"	// Fresh
.pc = * "colour ram"
.align $0100
colorbase:
.import binary "data/d800_comp.raw"

//</FRESHNESS>

.pc = $2600 "screendata"
screendata:
.import binary "data/screen.raw"

.pc = $2a00 "pixels"
.import binary "data/pixels.raw"

.pc = $3800
.fill $800,0


.pc = $4000
.fill $4000,[floor(2*random())*$03]+[floor(2*random())*$0c]+[floor(2*random())*$30]+[floor(2*random())*$c0]
