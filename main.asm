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
		jsr prepare_cover_sprites

		lda #0
		sta $d015

		:wait_frame()

		:d011($1b)
		:d012($f9)
		:set_irq(lower_border_irq)

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

		lda #border_colour
		sta $d020

		lda #0
		sta plex_ct
		sta $d01d


		jsr next_bottom_sprites
		jsr recolour_sprites

		:point_next_sprites([bottom_sprites/$40],screen_0)

		:point_next_sprites([bottom_sprites/$40]+7,screen_1)

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

.align $20
lower_split_irq:
		:open_irq()

		ldy #2
		:wait()

		:d011($1b)
		:d016($c8)

		lda #bottom_bg_colour
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

//		inc $d020

		ldy #2
		:wait()
		nop

		lda #screen_1_d018
		sta $d018

		jsr next_bottom_sprites
		inc plex_ct

		:set_irq(plex_1_irq)
		:d012(base_plex+offset_plex*1+3)

		jsr next_bottom_sprites
	//	dec $d020

		:close_irq()
		rti

.align $20
plex_1_irq:
		:open_irq()

		:point_next_sprites([bottom_sprites/$40]+14,screen_0)

		lda #screen_0_d018
		sta $d018

		asl $d019

		//Sprite grigi
		lda #[bottom_sprites/$40]+21
		sta screen_1+$03f8
		sta screen_1+$03f9
		sta screen_1+$03fa

		//Continuo del disegno
		lda #[lower_border_sprites/$40]
		sta screen_1+$03fb
		lda #[lower_border_sprites/$40]+1
		sta screen_1+$03fc
		lda #[lower_border_sprites/$40]+2
		sta screen_1+$03fd

		lda #$fa
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009
		sta $d00b


		//Sprite grigio 0
		lda #$18
		sta $d000


		//lda #$38
		//sta $d015

		:set_irq(lower_border_irq)
		:d012($f8)

		:close_irq()
		rti

.align $20
lower_border_irq:
		:open_irq()


		inc $d020

		lda #$13
		sta $d011

		lda #$c0
		sta $d010

		//-------------------------
		//Sprites grigi 1-2
		lda #$18+48
		sta $d002

		lda #$18+[48*2]
		sta $d004
		//-------------------------

		lda #0
		sta $d021


		/*
		//-------------------------
		//Sprites colorati
		lda #$b0
		sta $d006

		lda #$b0+24
		sta $d008

		lda #$b0+24*2
		sta $d00a
		//-------------------------
		*/

		lda #DARK_GRAY
		sta $d027
		sta $d028
		sta $d029

		lda #$f8
		sta $d01c


		lda #BLUE
		sta $d025

		lda #PURPLE
		sta $d026

		lda #$7
		sta $d01d


		lda #screen_1_d018
		sta $d018

		//Sprite grigi
		lda #[bottom_sprites/$40]+21
		sta screen_0+$03f8
		sta screen_0+$03f9
		sta screen_0+$03fa

		//Continuo del disegno
		lda #[lower_border_sprites/$40]+21
		sta screen_0+$03fb

		lda #[lower_border_sprites/$40]+3
		sta screen_0+$03fc
		lda #[lower_border_sprites/$40]+4
		sta screen_0+$03fd
		lda #[lower_border_sprites/$40]+5
		sta screen_0+$03fe

		dec $d020


		lda #$0f
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009
		sta $d00b



		lda #$04
!:
		cmp $d012

		bcc !-
		asl $d019

		:set_irq(msx_irq)

		:d011($9b)
		:d012($0f) //Questo fa saltare ntsc (abbassare a $06 e mettere un wait nel msx irq)
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

		inc $d020
		jsr music.play

		dec $d020
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

.pc = $0900 "lower border sprites"
lower_border_sprites:
.import binary "data/lower_border_sprites.raw"

.pc = $d800 "colour ram"
.import binary "data/d800.raw"
