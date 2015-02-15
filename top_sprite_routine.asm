.import source "misc_macro.asm"
//Freshness

// Switching rasters
// *****************
.const	rst_sprite1		=	$130		// Top sprites
.const	rst_sprite2		=	$2f			// More sprites
.const	rst_sprite3		=	$34			// More sprites
.const	rst_stable		=	$36			// Stable irq
.const	rst_mdlswitch	=	$c2			// Middle block (bitmap)
.const	rst_msx			=	$f9			// Sid player

// Mode switch
// ***********
.const	vic_d011	=	$d011		// Change this for testing purpose
.const	mdlvalue	=	$3b			// Bitmap mode
.const	tnbvalue	=	$1b			// Char mode

// Zero page variables
// *******************
.const	switchmode	=	$c0	
.const	savex		=	$c1
.const	savey		=	$c2
.const	hix			=	$c3
.const	lox			=	$c4
.const	scrollcolor	=	$c5
.const	ptr			=	$c6
.const	bit1		=	$c8
.const	temp		=	$c9

// Colors
// ******
.const	d800scr		=	WHITE
.const	bgcolor		=	LIGHT_GRAY

// Pointers
// ********
.const	b1sprite	=	$4400		// Bank 1 sprite base
.const	logoswap	=	$fc00		// Swap zone

// Sprite def.
// ***********
.const	b0sprbs		=	[b0sprite&$3fff]/$40	// Sprite base (bank 0)
.const	b1sprbs		=	[b1sprite&$3fff]/$40	// Sprite base (bank 1)



	
// FPP Precalc'd tables	
// ********************
.align $0100	// -> D011: skip badlines and alternate EBCM/Char mode (gfx*2)
// Block sprite
sprblock:
.fill $40,$aa

.print "D011 table: "+toHexString(*)
d011table:
.fill 20,[[[19-i]*2]&6]+[[[i^1]&1]*$40]+$18+1

.var	d018values=List()
.for(var i=0;i<38;i++)	
	.eval	d018values.add([[$2e-floor(i/2)]&$f]+[16*[floor([i+5]/21)*2+1]])
	
// D018: change gfx (even)
.print "D018 table: "+toHexString(*)
d018table1:
.fill 19,d018values.get([18-i]*2)

// D018: change gfx (odd)
.print "D018 table: "+toHexString(*)
d018table2:
.fill 19,d018values.get([18-i]*2+1)


// Plexer
// ******
// Value modified on each FPP line (used for multiplexing)
.print "Plex on FPP tables [$80]: "+toHexString(*)
plexport:
.byte	$3f,$3f,$3f,$3f,$3f,$3f,$3f,$09,$07,$05
.byte	$3f,$3f,$3f,$3f,$3f,$3f,$09,$07,$05,$3f

plexvalue:
.byte	$33+42,$33+42,$33+42,$33+42,$33+42,$33+42,$33+42,$33+42,$33+42,$33+42
.byte	$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+00

// More crunching needed to realign the bitmap
// *******************************************
.print "Realign bitmap table: "+toHexString(*)
realign:
.fill 13,$18+[[i+7]&7]

convlogo:
.fill	15,[3*[i&1]]+[6*[i&2]]+[12*[i&4]]+[24*[i&8]]

masks:
.byte	$00,$00,$03,$03,$07,$07,$0f,$0f

spritedef:
.byte	sprblock/$40,sprblock/$40,b1sprbs+0,b1sprbs+1,b1sprbs+2,$1e,$1d,$00
.byte	sprblock/$40,sprblock/$40,b1sprbs+3,b1sprbs+4,b1sprbs+5,$1e,$1d,$00
.byte	sprblock/$40,sprblock/$40,b1sprbs+6,b1sprbs+8,b1sprbs+9,$1e,$1d,$00
.byte	sprblock/$40,sprblock/$40,b0sprbs+6+4,b0sprbs+8+4,b0sprbs+9+4,$1e,$1d,$00




initscroll:
	lda #d800scr
	ldx #39
!:
	sta $d800,x
	dex
	bpl !-
	sta scrollcolor
	lda #$00
	sta $3fff
	sta $79ff
	sta $7fff
	lda #$aa
	ldx #$3e
!:	
	sta $4000+sprblock,x
	dex
	bpl !-
	lda #bgcolor
	sta $d021
	sta $d022
	sta $d023
	lda #$ff
	sta $d015	
	rts

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

	
// *********************	
// Top sprite management
// *********************

irq_sprite1:
	lsr $d019
	pha	
	stx savex
	ldx #$09
!:
	lda sprite1tbl,x
	sta $d000,x
	lda sprite1tbl+$a,x
	sta $d00a,x	
	lda sprite1clr,x
	sta $d025,x
	lda sprite1def-2,x
	sta $07f6,x	
	dex
	bpl !-
	lda #$03
	sta $d017
	sta $d01d
	lda #$7f
	sta $d015
	lda #$ff
	sta $d01c
	lda #<irq_sprite2
	sta $fffe
	lda #>irq_sprite2
	sta $ffff			
	ldx savex
	lda #LIGHT_GREY
	sta $d021
	sta $d020
	lda #$c8
	sta $d016	
	pla
	rti
	
sprite1tbl:
.byte	$d8,$17,$08,$17,$38,$1e,$68,$1e,$80,$1e
.byte	$00,$09,$78,$09,$00,$00
.byte	$02,$18,rst_sprite2,$00
sprite1clr:
.byte	$f4,$fa									// Multicolor colors
.byte	$fb,$fb,$fe,$fe,$fe,$fb,$f1,$f9			// Sprite colors
sprite1def:
.byte   sprblock/$40,sprblock/$40,b0sprbs+1,b0sprbs+2,b0sprbs+3,b0sprbs,b0sprbs,$00


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
	lda #>irq_sprite3
	sta $ffff
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
	lda #$67
	sta $d01b
	// Update definitons
	lda #$63
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
	lda #b0sprbs+6
	sta $07fc		
	pla
	cli
	rti
	
	
// *********************
// Second sprite manager
// *********************
irq_sprite3:	
	pha
	// Line 52
	lda #b0sprbs+5
	sta $07fb	
	lda #b0sprbs+4
	sta $07fa		
	lda #$1f
	sta $d01c
	lda #rst_stable
	sta $d012
	lda #<irq_stable1
	sta $fffe
	lda #>irq_stable1
	sta $ffff	
	lda #$92
	sta $dd00		
	lda scrollcolor
	sta $d02c
	lsr $d019	
	pla
	rti
		
		
		
.align $0100
irq_stable1:
	pha					// 3+9+0/7
	sec					// 2
	lda #$33			// 2
	sbc $dc04			// 4
	sta *+4
	bpl *
	.fill $06,LDA_IMM	
	.byte BIT_ZP
	nop
	nop
	stx savex
	lda #$19
	ldx.a lox	
	lsr $d016			
	sta $d011			// 4		
	stx $d016			// 4			

	sty.a savey			// 4		
	ldy #18
	lda.a scrollcolor	// 4
	sta $d02d			// 4
	lda #bgcolor		// 2
	sta $d02c			// 4		
	.fill 7,NOP			// 16
	lsr $d016			// 6
	stx $d016			// 4		
	bit $ea				// 3		
		
		nop			// NTSC Fix
	logoloop_pos:	// Do FPP and plex sprites
		nop
		sta $d02d			// 4
		lda scrollcolor		// 3
		sta $d02c			// 4		
		lda plexport,y		// 4
		sta ll_mod+1		// 4
		lda d018table1,y	// 4
		sta $d018			// 4
		lda d011table,y		// 4
		lsr $d016			// 6
		sta $d011			// 4
		stx $d016			// 4
		lda d018table2,y	// 4
		sta $d018			// 4
		lda plexvalue,y		// 4
	ll_mod:
		sta $d03f			// 4
		lda.a scrollcolor	// 4
		sta $d02d			// 4
		lda #bgcolor		// 2
		sta $d02c			// 4
		.fill 2,NOP			// 8
		lsr $d016			// 6
		stx $d016			// 4
		dey					// 2
		bpl logoloop_pos	// 3

	lda #$1f
	sta $d018
	nop
	lda #$1e
	sta $d011	
	lda #$93
	sta $dd00
	lda #$d8
	sta $d016		
	lda #$ff
	sta $d01c	
	lda #$33+63
	sta $d005
	sta $d007
	sta $d009	
	lda #$41+42
	sta $d00d
	lda #$50
	sta $d00c
	
	lda #b0sprbs+4+6
	sta $07fa
	lda #b0sprbs+4+8
	sta $07fb
	lda #b0sprbs+4+9
	sta $07fc
	lda #b0sprbs+4+7
	sta $07fd
	.fill 6,NOP	
	
	ldy #$31
!:
	dey	
	bne !-		
	ldy #$18	
	nop
	lda #$93
	sta $dd00	
	nop
	ldy #00
	!:	
		lda realign,y
		sta $d011		
		.fill 16,NOP
		bit $fe
		iny
		cpy #13
		bcc !-
		
	lda #$38+[[12+7]&7]	
	sta $d011	
	lsr $d019
	cli
	lda #ORANGE
	sta $d021
	lda #rst_mdlswitch-1	// 2
	sta $d012				// 4
	lda #<irq_switch		// 2
	sta $fffe				// 4
	lda #>irq_switch		// 2
	sta $ffff				// 4
	lda #$00
	sta $d020
	dex
	cpx #$c8
	bcs !+
	inc hix
	ldx #$cf
!:
	stx lox		

	inc $d020
	txa
	and #$07
	tax
	lda masks,x	
	sta lftmask+1
	ldy #>[logo+[12*32]]
	lda hix
	lsr
	and #$1f
	sta fstbyte1+1
	bcc !+
	ldy #>[logoswap+[12*32]]
!:
	sty ptr+1	
	ldy #<[logo+[12*32]]
	sty ptr	
	clc
	adc #$01
	and #$1f
	sta secbyte1+1
	clc
	adc #$01
	and #$1f
	sta trdbyte1+1		
	clc
	adc #$14
	and #$1f
	sta fstbyte2+1
	clc
	adc #$01
	and #$1f
	sta secbyte2+1
	clc
	adc #$01
	and #$1f
	sta trdbyte2+1	
	ldx #57
fstbyte1:
	ldy #$00
	lda (ptr),y
lftmask:
	and #$00
	sta $4780,x
secbyte1:	
	ldy #$00
	lda (ptr),y
	sta $4781,x
trdbyte1:	
	ldy #$00
	lda (ptr),y
	sta $4782,x
fstbyte2:
	ldy #$00
	lda (ptr),y
	sta $4740,x
secbyte2:	
	ldy #$00
	lda (ptr),y
	sta $4741,x
trdbyte2:	
	ldy #$00
	lda (ptr),y
	sta $4742,x	
	dex
	dex
	dex
	clc
	lda ptr
	adc #$20
	sta ptr
	lda #$00
	rol
	eor ptr+1	
	sta ptr+1
	cpx #$00
	bne fstbyte1
	dec $d020
	
	ldx savex
	ldy savey	
	pla
	rti
	
	
	
		
	
	
irq_switch:	
	pha
	lda #BLACK
	sta $d021	
	stx savex
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
	lda #<msx_irq
	sta $fffe
	lda #>msx_irq
	sta $ffff
	lda #$f9
	sta $d012
	lsr $d019
	pla
	rti
	


// Prepare $d800
// *************
CopyData:
	lda #$02
	sta bit1
	lda #[<colorbase]
	sta ptr	
	lda #[>colorbase]
	sta ptr+1
	ldx #$00	
cdloop:
	ldy #$00
!:
	lda (ptr),y
	pha
	lsr
	lsr
	lsr
	lsr
d81sta:
	sta $d800,x
	pla	
d82sta:	
	sta $d801,x
	lda #$00
	sta (ptr),y
	iny
	inx	
	inx
	bne !-
	inc d81sta+2
	inc d82sta+2
	clc
	lda ptr
	adc #$80
	sta ptr
	lda ptr+1
	adc #$00
	sta ptr+1
	cmp #[[>colorbase]+2]
	bne cdloop

	lda #$00
	ldx #$05
!:
	lda #$00
	sta $7a00,x
	sta $7b00,x
	txa
	axs #[$100-$8]
	cpx #$08
	bcs !-
	lda #$07
	axs #[$100-1]
	cpx #$07
	bne !-
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
	ldx #$07
!:
	lda spritedef+$00,x
	sta $47f8,x
	lda spritedef+$08,x
	sta $4ff8,x
	lda spritedef+$10,x
	sta $57f8,x	
	lda spritedef+$18,x
	sta $03f8,x
	dex
	bpl !-
	rts

	
