// Raster line for stabilizing
// ***************************
.const	testline	=	1

// Constants
// *********

.const	 pal_line	=	63
.const	 ntsc_line	=	65


// Prepare routine for PAL/NTSC
// ****************************	
start_timer:	
	php	
	sei	
	lda #$7f
	sta $dc0d
	bit $dc0d	
	ldx #testline
	stx $d012	
	lda #<irq_timer1
	sta $fffe
	lda #>irq_timer1
	sta $ffff	
	lsr $d019
	cli
!:
	txa
	bne !-	
	plp
	rts


	
// Double raster stabilizer routine
// ********************************	
irq_timer1:	
	lsr $d019			// 6+9+0/7
	tsx					// 2
	inc $d012			// 6
	lda #<irq_timer2	// 2
	sta $fffe			// 4
	ldy #$00			// 2 Stop timer B
	sty $dc0e			// 4
	lda #[pal_line-1]	// 2 Set timer B to PAL line length
	sta $dc04			// 4	
	sty $dc05			// 4
	cmp (0,x)			// 6
	ldy #[testline+1]	// 2
	cli					// 2 - 55/62
	.fill 2,NOP			// 4 IRQ1
irq_timer2:	
	.if	([>[irq_timer1]]!=[>[irq_timer2]]) .error "Page crossed on timer module!"	
	.fill 2,NOP			// 4 IRQ1 IRQ2 (2nd IRQ +9+0/1)
	lda #$91			// 2 IRQ1 IRQ2
	txs					// 2 IRQ1 IRQ2
	ldx #$07			// W = 6+(X-1)*5 => 36
!:
	dex
	bne !-
	lsr $d019			// 6	
	cpy $d012			// 4	
	beq !+	
!:
	.if	([>[*-1]]!=[>[!-]]) .error "Page crossed on timer module!"	
	sta $dc0e,x	
	rti	


	