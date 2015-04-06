// Copy LUT 1 on LUT 0 (only pages 2 and 3)
copylut:
		ldy #$00
	!:
		lda $06c0,y
		sta $02c0,y
		lda $0700,y
		sta $0300,y
		dey
		bne !-
		lda #$80
		ldy #$3f
	!:
		sta $400,y
		dey
		bpl !-
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

		
