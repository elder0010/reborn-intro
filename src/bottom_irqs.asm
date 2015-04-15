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
		pha
        stx reset_x

        ldx #<plex_0_irq
        stx $fffe
        ldx #>plex_0_irq
        stx $ffff

        ldx #$cf
        stx $d012

        ldx #8
        :waitx()

		ldx #$13
		lda #$c8
        stx $d011
        sta $d016
		sax $d021

		ldx #$5
		:waitx()

		ldx #$1b
		lda #DARK_GRAY
		sta $d021
		stx $d011

		ldx reset_x
		asl $d019
		pla
		rti

//Seconda riga di sprites (sotto ai menti)
plex_0_irq:
		:open_irq()
		asl $d019

		ldy #2
		:wait()

		ldx #screen_1_d018
		jsr next_bottom_sprites
		inc plex_ct

		:set_irq(plex_1_irq)
		:d012(base_plex+offset_plex*1+2)

		ldx #screen_1_d018
		jsr next_bottom_sprites

		:close_irq()
		rti

plex_1_irq:
		:open_irq()
		
		cmp ($0,x)
	
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

lower_border_irq:
		:open_irq()

		.fill $3,NOP

		lda #DARK_GRAY
		sta $d027
		sta $d02d
		sta $d02e

		lda #$18
		sta $d000

		ldx #0
		stx $d025
		stx $d010
fixlobo:
		lda #$f3
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
/*
appunto x la stabilizzazione
dopo il busy wait di $d012 fai una cosa di questo genere:
lda #$01
ldx $dc04
sta $c000,x
poi fai partire, filla di 00 c000-c0ff
e lascialo andare (warpa)
poi checka in c000 dove t'ha scritto 1
così sappiamo il jittering

		dex
		ldy #24
		:wait()
		bit $24
		bit $24
		stx $d020
*/
		:set_irq(msx_irq)

		//:d011($9b)
		:d012($0f)
		//lda #$0f
		sta $d005
		sta $d007

		:close_irq()
		rti

//.align $20
msx_irq:
		:open_irq()
		asl $d019
		cli

		lda #screen_0_d018
		sta $d018

		jsr set_mdlirq

		lda #$ff
		sta $d015

		lda #$23
		sta $d001
		sta $d00d
		sta $d00f
		sta $d003
		lda #$00
		sta $d002

		lda $d017
		ora #$02
		sta $d017

		lda #18
		sta counter

		lda #2
		sta sprrow

		jsr updatelogo
        jsr write_char
introend:
		lda #0
		bne !+
halfdl:
		lda #0
		eor #$ff
		sta halfdl+1
		beq !+
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
		lda #$18|[[1]*$80]
		sta fix1stframe+1
		lda #$93
		sta fixlobo+1
		:close_irq()
		rti
