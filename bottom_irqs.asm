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

.const base_plex = $cf
.const offset_plex = $10

//.align $20
lower_split_irq:
        sty reset_y

        asl $d019
        bit $24

        ldy #<plex_0_irq
        sty $fffe
        ldy #>plex_0_irq
        sty $ffff

        ldy #$cf
        sty $d012

        ldy #7
        :wait()

        ldy #$1b
        sty $d011
        ldy #$c8
        sty $d016

        ldy #0
        sty $d021

		ldy #$17
		:wait()

		ldy #DARK_GRAY
		sty $d021

        ldy reset_y
		rti

//.align $10
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

//.align $20
plex_1_irq:
		:open_irq()

		//ldy #2
		ldy #$01
		:wait()

		//:point_next_sprites([bottom_sprites/$40]+14,screen_0)
		//fatto senza macro
		ldx #0
		lda #[bottom_sprites/$40]+14
!:
		sta screen_0+$03f9,x
		clc
		adc #1

		inx
		cpx #7
		bne !-
		//fine cambio pt

		//Spritoni grigi
		lda #[sprblock0/$40]
		sta screen_1+$03f8
		sta screen_1+$03fe
		sta screen_1+$03ff

		lda #screen_0_d018 //switchone sopra le spalle
		sta $d018

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

		.fill $2,NOP
		bit $24

		lda #$18
		sta $d000

		lda #DARK_GRAY
		sta $d027
		sta $d02d
		sta $d02e

		ldx #0
		stx $d025
		stx $d010

		lda #$13
		sta $d011

		//-------------------------
		//Sprites grigi 1-2
		ldy #$18+48
		lda #$18+[48*2]
		sta $d00e
		sty $d00c
		//-------------------------

		stx $d021
		lda #screen_1_d018
		sta $d018

		lda #$c1
		sta $d017
		sta $d01d

		lda #BLUE
		sta $d025

		lda #PURPLE
		sta $d026

		//Spritoni grigi
		lda #[sprblock0/$40]

		sta screen_0+$03f8
		sta screen_0+$03fe
		sta screen_0+$03ff


		//Continuo del disegno
		lda #[lower_border_sprites/$40]+3
		sta screen_0+$03fa
		lda #[lower_border_sprites/$40]+4
		sta screen_0+$03fb

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

//.align $20
msx_irq:
		:open_irq()

		asl $d019

		cli

		lda #screen_0_d018
		sta $d018

		/*
		:set_irq(top_irq)

		:d011($3b)
		:d012($00)
		*/

		jsr set_mdlirq

		lda #$ff
		sta $d015

		lda #$23
		sta $d001
		sta $d00d
		sta $d00f

		lda #18
		sta counter

		lda #2
		sta sprrow


        jsr write_char

introend:
		lda #0
		bne !+
		inc text_delay
		lda text_delay
		cmp #text_wait_delay
		bne !+
		lda #JSR_ABS
		sta noline
		lda #INX
		sta storcaret
		//jsr reset_writer_pointers
		inc introend+1
!:


		jsr music.play

		:close_irq()
		rti
