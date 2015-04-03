// $41 bytes of code
// *****************

// Fade logo
// *********
updatelogo:
		lda startlogo+1
		beq ulfx
		dec startlogo+1
		rts
ulfx:
		lda startlogo
		bmi ulexit
		adc #$00				
		sta	startlogo	
		lsr
		tax		
		lda colortab-$31,x		
		jsr setscrollcolor		
		asl
		inx
		bcc !+
		ldx #$67
	!:
		stx sprite1tbl+$1b
ulexit:	
		rts

// Recolour sprites
// ****************		
recolour_sprites:
        ldx #7
        lda #BROWN
!:
        sta $d028,x
        dex
        bpl !-
        rts

// Ugly SID fix
// ************
fixsid:
		lda $13fb,x
		cmp #$1d
		lda $15fa,y
		bcc !+
		cpx #$07
		bne !+
		cmp #$21
		bne !+
		lda #$00
!:
		rts		
		
