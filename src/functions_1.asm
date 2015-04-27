// Copy FPP code high memory (F700)
copyfppcode:
		ldy #$00
		sty cptr
		sty cptr+2
		lda #$3a
		sta	cptr+1
		lda #>freshcode
		sta cptr+3
!:
		lda (cptr),y
		sta (cptr+2),y
		lda #$00
		sta (cptr),y
		dey
		bne !-
		inc cptr+1
		inc cptr+3
		bne !-
		rts		

		
						
next_bottom_sprites:
        //Sprites Y & PT
		stx $d018
        ldy plex_ct
        lda bottom_sprites_y,y
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f		
        rts
		
resetvic:		
		lda #$03
		sta $9a
		lda #$00
		sta $99
		ldx #$2f
cfloop:
		lda $ecb8,x
		cpx #$21
		beq cfskip
		cpx #$12
		beq cfskip
		sta $cfff,x
cfskip:
		dex
		bne cfloop
		rts

position_first_sprites_line:
		lda #0
        sta plex_ct

        lda #ORANGE
        sta $d026

        jsr next_bottom_sprites+3
        jsr recolour_sprites

		ldx #$0
		lda #[bottom_sprites/$40]
!:
		clc
		sta screen_0+$03f9,x //sta screen_1+$03f9,x
		adc #7
		sta screen_1+$03f9,x //sta screen_1+$03f9,x
		adc #<[1-7]
		inx
		cpx #7
		bne !-

        inc plex_ct

        lda #<[$b0+6*24]
        ldx #14
!:
        sta $d000,x
        sec
        sbc #24
        dex
        dex
        bne !-
		stx $d01b

        lda #$e0
        sta $d010

        rts		

