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

		lda #bottom_bg_colour
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

top_irq:
		:open_irq()
		asl $d019

		lda #top_bg_colour
		sta $d021

		:set_irq(bitmap_split_irq)
		:d012($7f)

		:close_irq()
		rti

bitmap_split_irq:
		:open_irq()
		asl $d019

		:set_irq(lower_split_irq)
		:d012($c2)

		ldx #bitmap_bg_colour
		nop
		:d011($3b)

		bit $24

		stx $d020
		stx $d021

		ldy #$f0
		:wait()

		lda #bottom_bg_colour
		sta $d020

		jsr reposition_sprites_x
		jsr next_bottom_sprites

		:close_irq()
		rti

lower_split_irq:
		:open_irq()
		asl $d019

		lda #bottom_bg_colour
		sta $d021

		:set_irq(msx_irq)
		:d012($f9)
		:d011($1b)


		:close_irq()
		rti

msx_irq:
		:open_irq()
		asl $d019

		lda #$33
		sta $d011

		lda #$fc
!:
		cmp $d012
		bne !-

		lda #$3b
		sta $d011

		:set_irq(top_irq)
		:d012($00)
		:d011($1b)

		lda #$ff
		sta $d015

		inc $d020
		jsr music.play
		dec $d020

		:close_irq()
		rti

.pc = * "functions"
.import source "functions.asm"

.pc = $3700 "bottom sprite plexer"
.import source "bottom_sprite_plexer.asm"


.pc = $a00 "logo_swinger"
.import source "top_sprite_routine.asm"

.pc = $2600 "screendata"
screendata:
.import binary "data/screen.raw"

.pc = $2a00 "pixels"
.import binary "data/pixels.raw"

.pc = bottom_sprites "bottom sprites"
.import binary "data/bottom_sprites.raw"

.pc = $d800 "colour ram"
.import binary "data/d800.raw"
