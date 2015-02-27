.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

:BasicUpstart2(code)

.pc = $2000 "charset"
.import binary "data/charset.raw"
.fill 8,$ff
.fill 7,$ff
.byte 0

.pc = $2110 "code"
code:
		sei
		.if(PLAY_MUSIC){
			lda #0
			sta $d015
			sta $d011
			jsr music.init
		}

		:kernal_off()
		:turn_off_cia_turn_on_raster_irq()
		:kill_nmi()

		lda #border_colour
		sta $d020

		lda #bottom_bg_colour
		sta $d021

		:bank_0()

		jsr copy_screendata
		jsr prepare_chars_under_sprites //da chiamare dopo copy_screen_data o rompe i dati
		jsr prepare_cover_sprites

		:d012($0f)
		:d011($90)
		:set_irq(msx_irq)

		cli

		jmp *

top_irq:
		:open_irq()
		asl $d019

		lda #top_bg_colour
		sta $d021

		lda #0
		sta $d017

		lda #18
		sta counter

		lda #2
		sta sprrow

		lda #$fe
		sta $d015

		jsr position_sideborder_sprites

		:d011($1b)
		:set_irq(stabilizer_irq_pal)
		:d012(stabilizer_irq_line)

		:close_irq()
		rti

.import source "sideborder_pal.asm"

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

.macro point_next_sprites_lower_border(base,screen){
		ldx #0
		lda #base //lda #[bottom_sprites/$40]+7
!:
		sta screen+$03f9,x //sta screen_1+$03f9,x
		clc
		adc #1

		inx
		cpx #5
		bne !-
}



bitmap_split_irq:

/*
		sta reset_a
		stx reset_x
		sty reset_y

		asl $d019
*/

		asl $d019
		:set_irq(lower_split_irq)
		:d012($c2)


		ldy #$f0
		:wait()

		//Prima linea di sprites sotto le facce
		jsr position_first_sprites_line

	//	:close_irq()
		lda reset_a
		ldx reset_x
		ldy reset_y

		rti


.const base_plex = $cf
.const offset_plex = $10

.align $20
lower_split_irq:
		:open_irq()

		.fill $2,NOP
		bit $24

		:d011($1b)
		:d016($c8)

		lda #DARK_GRAY
		sta $d021

		asl $d019

		:set_irq(plex_0_irq)
		:d012($cf)

		:close_irq()
		rti

.align $20
//Seconda riga di sprites (sotto ai menti)
plex_0_irq:
		:open_irq()
		asl $d019

		ldy #2
		:wait()
		nop
		nop

		lda #screen_1_d018
		sta $d018

		jsr next_bottom_sprites
		inc plex_ct

		:set_irq(plex_1_irq)
		:d012(base_plex+offset_plex*1+2)

		jsr next_bottom_sprites

		:close_irq()
		rti

.align $20
plex_1_irq:
		:open_irq()

		ldy #2
		:wait()

		:point_next_sprites([bottom_sprites/$40]+14,screen_0)

		lda #screen_0_d018
		sta $d018

		//Spritoni grigi
		lda #[bottom_sprites/$40]+21
		sta screen_1+$03f8
		sta screen_1+$03fe
		sta screen_1+$03ff

		//Continuo del disegno
		lda #[lower_border_sprites/$40]
		sta screen_1+$03f9
		lda #[lower_border_sprites/$40]+1
		sta screen_1+$03fa
		lda #[lower_border_sprites/$40]+2
		sta screen_1+$03fb

		lda #$fa
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d00d
		sta $d00f

		:set_irq(lower_border_irq)
		:d012($f9)
		asl $d019

		:close_irq()
		rti

.align $20
lower_border_irq:
		:open_irq()

		lda #LIGHT_GRAY
		sta $d020

		lda #DARK_GRAY
		sta $d027
		sta $d02d
		sta $d02e

		lda #$18
		sta $d000

		ldx #0
		stx $d025
		stx $d010

		lda #$13
		sta $d011

		//-------------------------
		//Sprites grigi 1-2
		lda #$18+48

		stx $d021

		sta $d00c

		lda #$18+[48*2]
		sta $d00e
		//-------------------------

		lda #screen_1_d018
		sta $d018

		lda #$c1
		sta $d017
		sta $d01d

		lda #BLUE
		sta $d025

		lda #PURPLE
		sta $d026

		//Continuo del disegno
		lda #[lower_border_sprites/$40]+3
		sta screen_0+$03fa
		lda #[lower_border_sprites/$40]+4
		sta screen_0+$03fb

		//Spritoni grigi
		lda #[bottom_sprites/$40]+21

		sta screen_0+$03f8
		sta screen_0+$03fe
		sta screen_0+$03ff

		asl $d019

		:set_irq(msx_irq)

		:d011($9b)
		:d012($0f)
		//lda #$0f
		sta $d005
		sta $d007

		:d016($d8)

		:close_irq()
		rti

.align $20
msx_irq:
		:open_irq()

		asl $d019

		//ldy #$1 //$50 PAL ->
		//:wait()

		lda #screen_0_d018
		sta $d018

		:set_irq(top_irq)

		:d011($3b)
		:d012($00)

		lda #$ff
		sta $d015

		lda #$23
		sta $d001
		sta $d00d
		sta $d00f

		jsr music.play

		:close_irq()
		rti


.pc = * "functions"
.import source "functions.asm"

.pc = $5600 "screen data"
screendata:
.import binary "data/screen.raw"

.pc = $2800 "sideborder sprites"
sideborder_sprites:
.import binary "data/sideborder_sprites.raw"

.pc = $2a00 "pixels"
.import binary "data/pixels.raw"

.pc = bottom_sprites "bottom sprites"
.import binary "data/sprit.raw"

.pc = $0ec0 "lower border sprites"
lower_border_sprites:
.import binary "data/lower_border_sprites.raw"

.pc = $8000 "colour ram"
colour_ram:
.import c64 "data/colors"
