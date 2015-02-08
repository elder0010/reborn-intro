//Freshness

// Switching rasters
// *****************
.const	rst_setsprite	=	$33			// Set logo sprites
.const	rst_stable		=	$33+8		// Stable irq
.const	rst_mdlswitch	=	$33+8*8		// Middle block (bitmap)
.const	rst_tnbswitch	=	$33+9*16	// Top&Bottom block (char)
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
	lda #$33+8
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f
	lda #$fe
	sta $d015
	sta $d017
	sta $d01d
	lda #$00
	sta $d01c
	lda #$01	
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e		
	lda #$08
	sta $d002
	lda #$38
	sta $d004
	lda #$68
	sta $d006
	lda #$98
	sta $d008
	lda #$c8
	sta $d00a
	lda #$f8
	sta $d00c
	lda #$28
	sta $d00e
	lda #$80
	sta $d010
	lda #$00
	sta $07f9
	sta $07fa
	sta $07fb
	sta $07fc
	sta $07fd
	sta $07fe
	sta $07ff	
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
	pla						// 4
	pla						// 4
	pla						// 4
	stx savex				// 3
	ldx #$06				// 2 Row counter
	lda $d012				// 4
	cmp $d012				// 4 63/00
	beq !+				
!:						// 3
	sty.a savey			// 4	
	lda #$d0			// 2
	sta $d016			// 4
	lda #$d8
	sta $d016
	.fill 
	
	pla					
	rti
	
	
irq_switch:
	pha
	jsr waitrtn
	lda switchmode
	sta vic_d011	
	eor #[mdlvalue^tnbvalue]
	sta switchmode
	cmp #mdlvalue
	bne !+	
	lda #<msx_irq
	sta $fffe
	lda #>msx_irq
	sta $ffff
	lda #$f9
	bne !++2
!:
	lda #rst_tnbswitch-1
	sta $d012
	lsr $d019
	pla
	rti
	

waitrtn:
	jsr *+3
	jsr *+3
	rts
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