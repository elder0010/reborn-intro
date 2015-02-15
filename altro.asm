// Build FPP logo
// **************
preparesbsprite:
	lda #$07
	sta ptr
	lda #$40
	sta ptr+1
	ldy #$00
	clc
rowloop:
	ldx #$00	
halfloop:	
	lda logo
	pha		
	lsr
	lsr
	lsr
	lsr
	tax
	lda convlogo,x
	sta (ptr),y
	tya
	clc
	adc #$08
	tay
	pla
	and #$0f
	tax
	lda convlogo,x
	sta (ptr),y
	tya
	clc
	adc #$08
	tay	
	inc halfloop+1
	bcc halfloop
	lax halfloop+1
	and #$3f	
	beq !+
	clc
	lda ptr+1
	adc #$01
	sta ptr+1
	bne halfloop
!:	
	cpx #$00
	bne !+
	inc halfloop+2
!:
	clc
	lda ptr+1
	adc #$05
	sta ptr+1
	cmp #$80
	bcc rowloop
	ldx #$1f
swapsrc1:
	lda logo,x
	and #$0f
	asl
	asl
	asl
	asl
	sta temp
	inx
	txa
	and #$1f
	tax	
swapsrc2:	
	lda logo,x
	lsr
	lsr
	lsr
	lsr	
	ora temp
swapdst:
	sta logoswap,x
	cpx #$1f
	bcc swapsrc1
	lda swapsrc1+1
	adc #$1f
	sta swapsrc1+1
	sta swapsrc2+1
	sta swapdst+1
	php
	lda swapsrc1+2
	adc #$00
	sta swapsrc1+2
	sta swapsrc2+2
	plp
	lda swapdst+2
	adc #$00
	sta swapdst+2	
	cmp #[[>logoswap]+2]
	bne swapsrc1
	rts
	

