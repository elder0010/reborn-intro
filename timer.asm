// Raster line for stabilizing
// ***************************
.const	testline	=	1

// Constants
// *********

.const	 pal_line	=	63
.const	 ntsc_line	=	65


// Double raster stabilizer routine
// ********************************	
irq_timer1:			
	inc $d012			// 6+9+0/7
	lda #<irq_timer2	// 2
	sta $fffe			// 4
	dex 				// 2 Stop timer B [X => 0]
	stx $dc0e			// 4
	lda #[pal_line-1]	// 2 Set timer B to PAL line length
	sta $dc04			// 4	
	stx $dc05			// 4
	tsx					// 2+9+0/1
irq_timer2:	
	.if	([>[irq_timer1]]!=[>[irq_timer2]]) .error "Page crossed on timer module!"						
	ldy #[testline+1]	// 2
	cmp (0,x)			// 6 IRQ1+IRQ2 (2nd IRQ +9+0/1)
	lsr $d019			// 6 IRQ1+IRQ2
	cli					// 2 IRQ1+IRQ2 - (End of IRQ1 -> 55/62)
	txs					// 2 IRQ1+IRQ2	
	nop					// 2 IRQ1+IRQ2
	nop 				// 2 IRQ1+IRQ2
	lda #$08			// 2 IRQ1+IRQ2 - (End of IRQ1 jitter) [IRQ2: W = 6+(asl(A)-1)*5 => 26]
!:
	asl					// 2
	bcc !-	
	ldx #$91			// 2 Here A=0
	cpy $d012			// 4	
	beq !+	
!:
	.if	([>[*-1]]!=[>[!-]]) .error "Page crossed on timer module!"	
	stx $dc0e
	rti	


// Prepare routine for PAL/NTSC
// ****************************	
start_timer:	
	php	
	sei
	ldx #testline
	stx $d012	
	lda #<irq_timer1
	sta $fffe
	lda #>irq_timer1	// This is !=0
	sta $ffff	
	lsr $d019
	cli
!:
	tay
	bne !-	
	plp
	rts	