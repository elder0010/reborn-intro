// Zero page
// *********

.const	done		=	$f0
//.const	videomode	=	$80		// 0 PAL, 1 NTSC => This must be set outside this routine

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
	lda #$01
	sta $d012
	sta done	
	lda #<irq_timer1
	sta $fffe
	lda #>irq_timer1
	sta $ffff	
	lsr $d019
	cli
!:
	lda done
	bne !-	
	plp
	rts


	
// Double raster stabilizer routine
// ********************************	
irq_timer1:	
	lsr $d019			// 6+9+0/7
	pha					// 3
	inc $d012			// 6
	lda #<irq_timer2	// 2
	sta $fffe			// 4
	lda #>irq_timer2	// 2
	sta $ffff			// 4
	lda #$00			// 2 Stop timer B
	sta $dc0e			// 4
	lda #[pal_line-1]	// 2 Set timer B to PAL line length
	sta $dc04			// 4
	ldy #$00			// 2
	sty $dc05			// 4
	cli					// 2 - 56/63
irq_timer2:	
	.fill 5,NOP			// 10
	cmp ($0,x)			// 6
	cmp ($0,x)			// 6
	lsr $d019			// 6	
	sty.a done			// 4
	pla					// 4+9+0/1
	pla					// 4
	pla					// 4	
	lda #$91			// 2	
	ldx $d012			// 4
	cpx $d012			// 4	
	beq !+	
!:
	.if	([>[*-1]]!=[>[!-]]) .error "Page crossed on timer module!"	
	sta $dc0e,y
	pla
	rti	


	