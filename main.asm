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

		lda #$c8
		sta $d016

		lda #$1a
		sta $d018

		jsr copy_screendata
		jsr prepare_chars_under_sprites //da chiamare dopo copy_screen_0data o rompe i dati

		lda #0
		sta $d015

		:wait_frame()

		:d011($1b)
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

		lda #0
		sta plex_ct

		inc $d020

		jsr reposition_sprites_x
		jsr next_bottom_sprites
		jsr recolour_sprites

		dec $d020


		lda d025_colours
		sta $d025

		lda d026_colours
		sta $d026


		inc plex_ct

		:close_irq()
		rti

lower_split_irq:
		:open_irq()
		asl $d019

lda #2
sta $d020

		:d016($c8)

		lda #bottom_bg_colour
		sta $d021

		ldx plex_ct
		cpx #1
		beq !+

		lda plex_d012_table,x
		sta $d012

		jsr next_bottom_sprites
		inc plex_ct

		jmp anotherplex
!:

		:set_irq(msx_irq)
		:d012($f9)
		:d011($1b)

anotherplex:

lda #0
sta $d020

		:close_irq()
		rti


.align 4
plex_d012_table:
.const base_plex = $e2
.for(var x=0;x<4;x++){
	.byte base_plex + [x*20]
}

msx_irq:
		:open_irq()
		asl $d019

		lda #$13
		sta $d011

		lda #$fc
!:
		cmp $d012
		bne !-

		lda #$ff
		sta $d015

		:set_irq(top_irq)

		lda #$1b
		sta $d011

		:d012($00)

		:d016($d8)
	//	inc $d020
		jsr music.play
	//	dec $d020

		:close_irq()
		rti

.pc = * "functions"
.import source "functions.asm"

.pc = $3700 "bottom sprite plexer"
.import source "bottom_sprite_plexer.asm"


.pc = $a00 "logo_swinger"
.import source "top_sprite_routine.asm"

.pc = $2600 "screen data"
screendata:
.import binary "data/screen.raw"

.pc = $2a00 "pixels"
.import binary "data/pixels.raw"

.pc = bottom_sprites "bottom sprites"
.import binary "data/bottom_sprites.raw"


.pc = $d800 "colour ram"
.import binary "data/d800.raw"
