ntsccheck:
nt1:
		lda $d012
nt2:
		cmp $d012
		beq nt2
		bmi nt1
		cmp #$20
		bcc !+
		rts		
!:
		lda #$20
		ldx #$00	
	!:
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
		dex
		bne !-
		lda #$1b
		sta $d011
ntscloop:
		lda ntsctext,x
		beq !+
		sta $0400,x
		inx
		bne ntscloop
!:	
		jsr check_fire_space
		bne !-
		
