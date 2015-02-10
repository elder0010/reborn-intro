.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

:BasicUpstart2(code)

.pc = $2000 "code"
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

		lda #screen_0_d018
		sta $d018

		:set_irq(bitmap_split_irq)
		:d012($7f)

		:close_irq()
		rti


.macro point_next_sprites(base,screen){
		ldx #0
		lda #base //lda #[bottom_sprites/$40]+7
!:
		sta screen+$03f9,x //sta screen_1+$03f9,x
		clc
		adc #1

		inx
		cpx #7
		bne !-
}

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

		lda #screen_0_d018
		sta $d018

		jsr next_bottom_sprites
		jsr recolour_sprites

		:point_next_sprites([bottom_sprites/$40],screen_0)

		inc plex_ct

		lda #$b0
		ldx #0
!:
		sta $d002,x
		clc
		adc #24
		inx
		inx
		cpx #14
		bne !-

		lda #$e0
		sta $d010

		lda #$ff
		sta $d01c

		lda d025_colours
		sta $d025

		lda d026_colours
		sta $d026

		:close_irq()
		rti


.const base_plex = $cf
.const offset_plex = $10

lower_split_irq:
		:open_irq()
		asl $d019

		:d016($c8)
		:d011($1b)

		lda #bottom_bg_colour
		sta $d021

		:set_irq(plex_0_irq)
		:d012(base_plex)

		:close_irq()
		rti

plex_0_irq:
		:open_irq()
		asl $d019

		jsr next_bottom_sprites
		inc plex_ct

		lda #screen_1_d018
		sta $d018

		:point_next_sprites([bottom_sprites/$40]+7,screen_1)

		:set_irq(plex_1_irq)
		:d012(base_plex+offset_plex*1+3)

		jsr next_bottom_sprites

		:close_irq()
		rti


plex_1_irq:
		:open_irq()

		:point_next_sprites([bottom_sprites/$40]+14,screen_0)

		lda #screen_0_d018
		sta $d018

		asl $d019

		inc plex_ct
		jsr next_bottom_sprites


		:set_irq(msx_irq)
		:d012($f9)

		:close_irq()
		rti

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


.pc = $2600 "screen data"
screendata:
.import binary "data/screen.raw"

.pc = $2a00 "pixels"
.import binary "data/pixels.raw"

.pc = bottom_sprites "bottom sprites"
.import binary "data/sprit.raw"


.pc = $d800 "colour ram"
.import binary "data/d800.raw"
