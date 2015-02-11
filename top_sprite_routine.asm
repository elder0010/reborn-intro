//Freshness

// Switching rasters
// *****************
.const	rst_setsprite	=	$33			// Set logo sprites
.const	rst_stable		=	$33+8		// Stable irq
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

// Colors
// ******
.const	d800scr		=	WHITE
.const	bgcolor		=	LIGHT_GRAY


initscroll:
	lda #d800scr
	ldx #39
!:
	sta $d800,x
	dex
	bpl !-
	sta scrollcolor
	lda #$00
	sta $79ff
	sta $7fff
	lda #$ff
	ldx #$3e
!:
	sta $7fc0,x
	sta $3fc0
	dex
	bne !-
	lda #bgcolor
	sta $d021
	rts

set_mdlirq:
	lda #rst_setsprite-2
	sta $d012
	lda #<irq_setsprite
	sta $fffe
	lda #>irq_setsprite
	sta $ffff			
	rts

// TO DO: Manage horizontal movement
// *********************************
irq_setsprite:	
	lsr $d019
	lda #rst_stable-2
	sta $d012
	lda #<irq_stable1
	sta $fffe
	lda #>irq_stable1
	sta $ffff	
	pha
	lda #rst_stable
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	lda #$3e
	sta $d01b	
	lda #$7f
	sta $d015
	lda #$71
	sta $d017
	sta $d01d
	lda #$0e
	sta $d01c
	lda #BLUE
	sta $d026
	lda #ORANGE
	sta $d025
	lda #PURPLE	
	sta $d028
	sta $d029
	sta $d02a	
	lda #DARK_GREY
	sta $d02b	
	sta $d02c	
	lda lox	
	and #$07
	ora #$e0	
	sta $d000
	and #$07
	ora #$58	
	sta $d00c	
	lda #$38
	sta $d002
	lda #$50
	sta $d004
	lda #$78
	sta $d006
	lda #$c8
	sta $d008
	lda #$f8
	sta $d00a

	lda #$41
	sta $d010
	lda #$06
	sta $47f8
	lda #$07
	sta $47fe	
	lda #$ff
	sta $47f9
	sta $47fa
	sta $47fb
	lda #$ff
	sta $47fc
	sta $47fd	
	sta $07fc
	sta $07fd		
	lda $d021
	sta $d022	
	lda #$1b
	sta $d011	
	pla
	cli
	rti
	
irq_stable1:
	pha					// 3+9+0/7
	lsr $d019			// 6
	inc $d012			// 6
	lda #<irq_stable2	// 2
	sta $fffe			// 4
	lda #>irq_stable2	// 2
	sta $ffff			// 4
	cli					// 2
	.fill 16,NOP		// 32

irq_stable2:
	lsr $d019				// 6+9+0/1
	lda #mdlvalue			// 2
	sta switchmode			// 3
	lda #rst_mdlswitch-1	// 2
	sta $d012				// 4
	lda #<irq_switch		// 2
	sta $fffe				// 4
	lda #>irq_switch		// 2
	sta $ffff				// 4
	stx savex				// 3
	sty.a savey				// 4	
	ldx.a lox				// 4
	lda #$92				// 2
	sta $dd00				// 4
	ldy #$1c				// 2
	lda #rst_stable-1		// 2
	cmp $d012				// 4 63/00
	beq !+				
!:						// 3		
	nop					// 2
	lda #bgcolor		// 2
	sty $d011			// 4		
	stx $d016			// 4	
	ldy #20	
	logoloop:		
		nop
		sta $d02d			// 4	
		lda scrollcolor		// 3
		sta $d027			// 4		
		lda loporttable,y	// 4
		sta mod_io+1		// 4		
		lda d018table,y		// 4
		sta $d018			// 4
		lda d011table,y		// 4
		lsr $d016			// 6
		sta $d011			// 4		
		stx $d016			// 4
		lda hiporttable,y	// 4
		sta mod_io+2		// 4		
		lda iovaltable,y	// 4
	mod_io:
		sta $d000			// 4
		lda.a scrollcolor	// 4
		sta $d02d			// 4
		lda #bgcolor		// 2
		sta $d027			// 4
		.fill 2,NOP			// 4
		lsr $d016			// 6
		stx $d016			// 4		
		dey					// 2
		bpl logoloop		// 3
				
		lda #$93
		sta $dd00
		lda #$18
		sta $d018
		lda #$d8
		sta $d016		
		lda #$00
		sta $d01b
		
		ldy #10
	!:
		.fill 6,NOP
		lda realign,y
		sta $d011		
		.fill 11,NOP
		bit $fe
		dey		
		bpl !-
		

		
		bit $fe				
		and #$07		
		lda #$1f
		sta $d011
		.fill 7,NOP
		nop
		clc
		adc #$06
		and #$07		
		lda #$39
		sta $d011				
		
	cli
	dex
	cpx #$c8
	bcs !+
	inc hix
	ldx #$cf
!:
	stx lox	

	ldx savex
	ldy savey
	lda #BROWN
	sta $d021
	pla
	pla
	pla
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
	

waitrtn:
	jsr *+3
	jsr *+3
	rts
	
	
.align $0020
.print "D011 table: "+toHexString(*)
d011table:
.fill 21,[[[[20-i]*2]+6]&6]+[[i&1]*$40]+$18

.align $0020
.print "D018 table: "+toHexString(*)
d018table:
.fill 21,$10+[i&$f]

.align $0020
.print "Low port table: "+toHexString(*)
loporttable:
.byte $3f,$3f,$3f,$3f
.byte $09,$0b				// Block plex
.byte $03,$05,$07			// Second plex
.byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
.byte $03,$05,$07			// First plex

.align $0020
.print "High port table: "+toHexString(*)
hiporttable:
.byte $d0,$d0,$d0,$d0
.byte $d0,$d0
.byte $d0,$d0,$d0
.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
.byte $d0,$d0,$d0

.align $0020
.print "I/O value table: "+toHexString(*)
iovaltable:
.byte $d0,$d0,$d0,$d0
.byte rst_stable+42
.byte rst_stable+42
.byte rst_stable+42
.byte rst_stable+42
.byte rst_stable+42
.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
.byte rst_stable+21
.byte rst_stable+21
.byte rst_stable+21

.align $0020
.print "Realign: "+toHexString(*)
realign:
.fill 11,$18+[[[10-i]+7]&7]



	
/*
.pc=$2000
.var image = LoadPicture("data\top_chars.png")

.var cy
.var cx
.for (var row=0;row<12;row++){
 .for (var col=0;col<12;col++){
  .for (var y=0;y<21;y++)
   .for (var x=0;x<3;x++)
    {	
	 .if (mod(row,2)==0)
	     .if (y<3)  .eval cy=mod(156+ceil([row*39+y]/2)-1,156)
		     else   .eval cy=[row*39]/2+y-2
	 else
		 .if (y>17) .eval cy=[[row-1]*39]/2+28+[y/2]
			 else   .eval cy=[[row-1]*39]/2+19+y
	 .eval cx=col*3+x
	 .byte image.getMulticolorByte(cx,cy)
	 
	}
  .byte $00
 }
 .fill $01f8,0
 .fill 8,[row]*$10+i
}
*/