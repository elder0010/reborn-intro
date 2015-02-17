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
	lda videomode
	lsr
	lda #ntsc_line-1
	bcc !+	
	ldx #CMP_IZPX
	.byte BIT_ABS
!:
	ldx #NOP
	eor #[ntsc_line-1]^[pal_line-1]
	sta irq_t1_mode+1
	stx irq_t2_mode	
	sei	
	lda #$7f
	sta $dc0d
	bit $dc0d
	lda #$08
	sta $d012
	lda #$00
	sta done	
	lda #<irq_timer1
	sta $fffe
	lda #>irq_timer1
	sta $ffff	
	lsr $d019
	cli
!:
	lda done
	beq !-	
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
irq_t1_mode:
	lda #$00			// 2 Set timer B to PAL/NTSC line lenght
	sta $dc04			// 4
	lda #$00			// 2
	sta $dc05			// 4
	cli					// 2 - 50/57	
	.fill 6,NOP	
irq_timer2:
	pla					// 4+9+0/1
	pla					// 4
	pla					// 4
	lsr $d019			// 6
	lda #$01			// 2
	sta.a done			// 4
	cmp ($0,x)			// 6
	cmp ($0,x)			// 6
	cmp ($0,x)			// 6	
irq_t2_mode:		
	nop					// 2
	nop					// 2	
	lda $d012			// 4
	cmp $d012			// 4	
	beq !+	
!:
	.if	([>[*-1]]!=[>[!-]]) .error "Page crossed on timer module!"
	lda #$91
	sta $dc0e		
	pla
	rti	


	