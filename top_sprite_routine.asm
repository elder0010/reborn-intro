//Freshness


// Switching rasters
// *****************
.const	rst_sprite1		=	$120		// Top sprites
.const	rst_sprite2		=	$30			// More sprites
.const	rst_sprite3		=	$35			// More sprites
.const	rst_msx			=	$f9			// Sid player

// Zero page variables
// *******************
.const	savex		=	$c1			// Save x inside IRQ handler
.const	savey		=	$c2			// Save y inside IRQ handler
.const	lox			=	$c3			// D016 current value (C8-CF)
.const	hix			=	$c4			// Upper scroll position
.const	scrollcolor	=	$c5			// Logo color
.const	ptr			=	$c6			// Misc 16 bit pointer 
.const	temp		=	$c8			// Misc 8 bit temporary data
.const	dummy		=	$ca			// Dummy byte for timing
.const	movpos		=	$cb			// Current scroll index position
.const	fstpageval	=	$cc			// First d018/dd00 value

// Colors
// ******
.const	d800scr		=	WHITE
.const	bgcolor		=	LIGHT_GRAY

// Pointers
// ********
.const	b1sprite	=	$4400		// Bank 1 sprite base
.const	logoswap	=	$fc00		// Swap zone
.const	sprblock	=	$37c0		// Filled block sprite
.const	sbleft		=	$4780		// Sideborder sprite left
.const	sbright		=	$4740		// Sideborder sprite right
.const	logofpp		=	$4007		// FPP starting position (Last line FPP)

// Sprite def.
// ***********
.const	b0sprbs		=	[b0sprite&$3fff]/$40	// Sprite base (bank 0)
.const	b1sprbs		=	[b1sprite&$3fff]/$40	// Sprite base (bank 1)



.align $0100	
// FPP Precalc'd tables	
// ********************


// D018: create d018 list for next use
.var	fpplines=List()
.eval	fpplines.add(0,1,2,3,4,5,6,7,7,7,7,7,8,9,10,11,12,13,14,15)
.var	d018values=List()
.for(var i=0;i<39;i++)	
	.eval	d018values.add([[$f+fpplines.get(floor([i+1]/2))]&$f]+[16*[[floor([i+4]/21)*2+5]&$7]])

// D011: skip badlines and alternate EBCM/Char mode (gfx*2)
.print "D011 table: "+toHexString(*)
d011table:
.fill 19,[[[19-i]*2]&6]+[[[fpplines.get(i)^1]&1]*$40]+$18+1
	
// D018: change gfx (even)
.print "D018 table: "+toHexString(*)
d018table1:
.fill 19,d018values.get([18-i]*2+1)

// D018: change gfx (odd)
.print "D018 table: "+toHexString(*)
d018table2:
.fill 20,d018values.get([19-i]*2)


// Plexer
// ******
// Value modified on each FPP line (used for multiplexing sprites)

// D0xx ports
.print "Plex on FPP tables [$80]: "+toHexString(*)
plexport:
.byte	$3f,$3f,$3f,$0b,$0d,$3f,$3f,$09,$07,$05,$3f,$3f,$3f,$3f,$3f,$3f,$09,$07,$05

// Values to be assigned
plexvalue:
.byte	$33,$33,$33,$36+42,$36+42,$33+42,$33+42,$33+42,$33+42,$33+42,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21

masks:
.byte	$00,$03,$07,$0f

// Sprite definitions
// ******************
// To be copied on second bank
spritedef:
.byte	sprblock/$40,sprblock/$40,b1sprbs+0,b1sprbs+1,b1sprbs+2,$1e,$1d
.byte	sprblock/$40,sprblock/$40,b1sprbs+3,b1sprbs+4,b1sprbs+5,$1e,$1d
.byte	sprblock/$40,sprblock/$40,b1sprbs+6,b1sprbs+8,b1sprbs+9,$1e,$1d
.byte	sprblock/$40,sprblock/$40,b0sprbs+6+4,b0sprbs+8+4,b0sprbs+9+4,$1e,$1d

// VIC configuration at raster 0
sprite1tbl:
.byte	$d8,$17,$08,$17,$38,$1e,$68,$1e					// Sprites (0-3) coordinates
.byte	$80,$1e,$00,$09,$78,$09,$38,$60					// Sprites (4-7) coordinates
.byte	$02,$18,rst_sprite2,$00,$00,$ff					// D010 - D015
.byte	$c8,$03,$1e,$01,$01,$67,$ff,$03,$00,$00  		// D016 - D01F
.byte	LIGHT_GREY,LIGHT_GREY,bgcolor,bgcolor,bgcolor	// Border/Background colors
.byte	$f4,$fa											// Multicolor sprite colors
.byte	$fb,$fb,$fe,$fe,$fe,0,$f1,GREY					// Sprite colors
sprite1def:	// Sprite definitions
.byte   sprblock/$40,sprblock/$40,b0sprbs+1,b0sprbs+2,b0sprbs+3,b0sprbs,b0sprbs,b0sprbs+14


// Logo positions (a quarter)
// **************************
movement:
.fill	64,floor(127*sin(i*PI/128))


// Effect handler
// **************
// Call this inside an IRQ to create effect on next frame
set_mdlirq:
	lda #<rst_sprite1
	sta $d012
	lda #$18|[[>rst_sprite1]*$80]
	sta $d011
	lda #<irq_sprite1
	sta $fffe
	lda #>irq_sprite1
	sta $ffff			
	rts

	
// Top sprite management
// *********************
irq_sprite1:	
	pha	
	stx savex
	ldx #$2f	
i1loop:
	lda sprite1tbl,x
	sta $d000,x
	cpx #$08
	bcs !+
	lda sprite1def,x
	sta $07f8,x	
!:
	dex
	bpl i1loop
	lda #<irq_sprite2
	sta $fffe
	ldx savex
	pla
	rti


// *********************
// Second sprite manager
// *********************
irq_sprite2:
	lsr $d019
	pha	
	lda #rst_sprite3
	sta $d012
	lda #<irq_sprite3
	sta $fffe
	// Update coordinates
	lda #$36
	sta $d00b
	sta $d00d		
	lda #$33
	sta $d005
	sta $d007
	sta $d009		
	lda #$41
	sta $d001
	sta $d003
	// Update definitons
	lda #$e3
	sta $d01d
	sta $d017
	lda #$62
	sta $d010	
	// Line 50	
	lda lox
	and #$07
	ora #$e0
	sta $d00a
	eor #[$58^$e0]
	sta $d00c	
	lda.a scrollcolor
	sta $d02c
	lda #b0sprbs+4
	sta $07fa
	lda #b0sprbs+5
	sta $07fb
	lda #b0sprbs+6
	sta $07fc
	lda #b0sprbs+11
	sta $07fd
	pla	 	
	rti
	
	
// *********************
// Second sprite manager
// *********************
irq_sprite3:	
	pha
	stx savex
	sty savey		
	lda $dc04
	eor #$2f
	sta *+4
	bpl *
	.byte	LDA_IMM,LDA_IMM,LDA_IMM,LDA_IMM,LDA_IMM,LDA_IMM,BIT_ZP,NOP		
	lda fstpageval
	sta $d018
	sta $dd00	
	nop
	nop
	lda #b0sprbs+10
	sta $07fa
	ldx #b0sprbs+12
	stx $07fb
	inx
	stx $07fc
	lda #b0sprbs+15	
	sta $07fe
	lda #$1f
	sta $d01c	
	ldx.a lox			// 4
	ldy #19				// 2
	lda #$19			// 2	
	bne logo_start		// 4 Page cross
	
.align $0100		
	logoloop_pos:	// Do FPP and plex sprites		
		nop					// 2
		sta $d02d			// 4
		lda scrollcolor		// 3
		sta $d02c			// 4		
		lda plexport,y		// 4
		sta ll_mod+1		// 4
		lda d018table1,y	// 4
		sta $d018			// 4
		lda d011table,y		// 4
	logo_start:			
		lsr $d016			// 6
		sta $d011			// 4
		stx $d016			// 4		
		inc dummy			// 5
		lda d018table2,y	// 4
		sta $d018			// 4
		lda plexvalue,y		// 4
	ll_mod:
		sta $d03f			// 4
		lda scrollcolor		// 4
		sta $d02d			// 4
		lda #bgcolor		// 2
		sta $d02c			// 4		
		lsr $d016			// 6
		stx $d016			// 4		
		dey					// 2
		bpl logoloop_pos	// 3
	ldy #$93
	sty $dd00
	ldx #$07
	// DMA delay
	// *********
	lda #$1e
	sax $d011			
	sta $d018
	lda #$03
	sta $d017	
	lda #$c3
	sta $d01d
	lda #$50
	sta $d00a
	lda #$68
	sta $d00c
	lda #$d8
	sta $d016		
	lda #$3f
	sta $d01c
	lda #$02
	sta $d010
	lda #$33+63
	sta $d005
	sta $d007
	sta $d009	
	lda #LIGHT_BLUE
	sta $d02c
	lda #ORANGE
	sta $d02d	
	ldy #$2f
!:
	dey	
	bne !-
	btmcrunch:					
		inc $d011-7,x	// Line crunch
		lda #$10		// W = 6+5*(ASL_No.-1) => 21
	!:
		asl
		bcc !-
		cpy #$05
		bcc wtskip
		inc dummy
	wtskip:	
		cpy #12
		beq !+
		nop
		iny		
		bcc btmcrunch
!:
	lda #$38+[[12+7]&7]	
	sta $d011	
	lsr $d019
	cli
	lda #ORANGE
	sta $d021
	lda #rst_msx			// 2
	sta $d012				// 4
	lda #<msx_irq			// 2
	sta $fffe				// 4
	lda #>msx_irq			// 2
	sta $ffff				// 4
	
	inc movpos	// Next logo position
	lda movpos	// Manage 2°/4° sector
	anc #$3f	// AND + clear carry
	bit movpos
	bvc !+
	eor #$ff
	adc #$40	// Carry always cleared after this
!:
	tax	
	lda movement,x	
	bit movpos	// Manage 3°/4° sector
	bpl !+
	eor #$ff	
	adc #$01	
!:
	tax
	anc #$f8	// Carry cleared
	bpl	!+
	ora #$03
	sec
!:	
	ror
	ror
	ror	
	eor #$ff
	adc #$01
	sta hix		// Save 5 MSb
	txa
	and #$07
	ora #$c8
	sta lox		// Save 3 LSb

		
	// Sideborder sprite copy
	// **********************	
	alr #$06
	tax
	lda masks,x	
	sta lftmask+1	
	lda hix
	adc #$13
	alr #$3f	
	ldy #>[logoswap+[14*32]]	
	bcc !+
	ldy #>[logo+[14*32]]
!:
	sty ptr+1	
	ldy #<[logoswap+[14*32]]
	sty ptr	
	ldx #$1f
	clc
	sax fstbyte1+1
	adc #$01	
	sax secbyte1+1	
	adc #$01	
	sax trdbyte1+1			
	adc #$15	
	sax fstbyte2+1	
	adc #$01	
	sax secbyte2+1	
	adc #$01	
	sax trdbyte2+1	
	ldx #57
fstbyte1:
	ldy #$00
	lda (ptr),y
lftmask:
	and #$00
	sta sbleft,x
secbyte1:	
	ldy #$00
	lda (ptr),y
	sta sbleft+1,x
trdbyte1:	
	ldy #$00
	lda (ptr),y
	sta sbleft+2,x
fstbyte2:
	ldy #$00
	lda (ptr),y
	sta sbright,x
secbyte2:	
	ldy #$00
	lda (ptr),y
	sta sbright+1,x
trdbyte2:	
	ldy #$00
	lda (ptr),y
	sta sbright+2,x	
	dex
	dex
	dex
	cpx #[8*3]
	bcc contlogo
	cpx #[12*3]
	bcc skiplogo
contlogo:
	sec
	lda ptr
	sbc #$20
	sta ptr	
	adc #$01
	and #$01
	eor ptr+1	
	sta ptr+1
skiplogo:	
	cpx #-3
	bne fstbyte1
	// Charscreen copy
	// ***************
	lda hix
	ldx #39
	clc
!:
	sbc #$80
	anc #$3f
	ora #$40
	sta $0400,x
	dex
	bpl !-			
	
	ldx savex
	ldy savey	
	pla
	rti
		
		
		
		
		
		
		
		
		

// *********************
// Scroll initialization
// *********************

initscroll:	
// Prepare D800
// ************
	lda #<colorbase
	sta ptr	
	lda #>colorbase
	sta ptr+1
	ldx #$00	
	ldy #$00	
d8loop:
	lda (ptr),y
d82sta:	
	sta $d801,x		
	lsr
	lsr
	lsr
	lsr
d81sta:
	sta $d800,x
	lda #$00
	sta (ptr),y
	iny
	bne d8skip
	inc ptr+1
d8skip:
	inx	
	inx
	bne d8loop	
	inc d81sta+2
	inc d82sta+2
	lda ptr+1
	cmp #[[>colorbase]+2]
	bne d8loop

// Clear line 5/6 of first definition ($D018 <= $xe)
// *************************************************
	ldx #$06
!:
	lda #$00
	sta $7a00,x
	sta $7b00,x
	txa
	axs #[$100-$8]
	cpx #$08
	bcs !-

// Copy sprites to bank 1
// **********************
	ldx #$00
!:
	lda b0sprite+$4*$40,x
	sta b1sprite,x
	lda b0sprite+$8*$40,x
	sta b1sprite+$100,x
	lda b0sprite+$c*$40,x
	sta b1sprite+$200,x		
	dex
	bne !-
	
// Copy sprite pointers
// ********************	
	ldx #$06
!:
	lda spritedef+$00,x
	sta $57f8,x
	lda spritedef+$07,x
	sta $5ff8,x
	lda spritedef+$0e,x
	sta $47f8,x	
	lda spritedef+$15,x
	sta $03f8,x
	dex
	bpl !-

// Build FPP logo
// **************
	lda #<logofpp	// Prepare char definitions
	sta ptr
	lda #>logofpp
	sta ptr+1
	ldy #$00	
	ldx #$00
rowloop:	
	lda logo,x		// Load "compressed" byte
	sta temp		// Store in temp
doublechar:
	lda #$01		// Set exit condition
bitloop:
	asl temp		// Get bit
	php
	rol				// Stuff it once
	plp
	rol				// Stuff it twice
	bcc bitloop		// Loop 4 times (1->4->10->40->C)
	sta (ptr),y
	tya	
	adc #$07		// Carry always set => +8
	tay
	and #$08		// If (y&8) then 
	bne doublechar	// we need to compute the low nibble of temp
	inx				// Ok, next byte
	bcc rowloop		// Till we need to change destination page
	bne !+			// End of source page?
	inc rowloop+2	// Change source page
!:
	txa
	and #$3f
	bne !+			// Here Y = A = 0, Z Flag refer to X status	
	lda #$04
!:		
	and #$0f
	adc ptr+1		// [ptr&3]==0 -> EBCM . [ptr&3]==1 -> normal char mode
	sta ptr+1
	bpl rowloop		// Stop at the of bank 1

	stx $79ff		// TEST <- DA LEVARE!!!
	stx $7fff		// Needed!
	
// Copy logoswap
// *************	
	ldx #$20		// Create swapped nibbles table for sideborder sprites
	ldy #$10
swapsrc1:
	lda logo-1,x	
	asl
	asl
	asl
	asl
	sta temp
	lda #$1f
	axs #[$100-1]
swapsrc2:	
	lda logo-1,x
	lsr
	lsr
	lsr
	lsr	
	ora temp
swapdst:
	sta logoswap-1,x
	cpx #$20
	bcc swapsrc1
	lda swapsrc1+1
	adc #$1f
	sta swapsrc1+1
	sta swapsrc2+1
	sta swapdst+1
	bcc !+
	inc swapsrc1+2
	inc swapsrc2+2
	inc swapdst+2
!:
	dey
	bne swapsrc1

// Prepare first line
// ******************
	ldx #$3f
!:	
	lda #$aa
	sta $4000+sprblock-1,x
	sta sprblock-1,x
	lda #d800scr	
	sta $d800-1,x
	dex
	bne !-
	sta scrollcolor	
	lda #$c8
	sta lox	
	lda #$5e
	sta fstpageval	
	rts
