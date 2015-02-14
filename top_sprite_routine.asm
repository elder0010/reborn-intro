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

// Colors
// ******
.const	d800scr		=	WHITE
.const	bgcolor		=	LIGHT_GRAY

.const	sprbs		=	$3700/$40	// Sprite base (first bank)

CopyData:
	ldx #$00
!:
	lda $8000,x
	sta $d800,x
	lda $8100,x
	sta $d900,x
	lda $8200,x
	sta $da00,x
	lda $8300,x
	sta $db00,x
	dex
	bne !-
	rts

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
	inc $d020
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
	lda #$60
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
	dec $d020
	lda #LIGHT_GREY
	sta $d021	
	pla
	rti
	
sprite1tbl:
.byte	$00,$09,$78,$09,$38,$1e,$68,$1e,$80,$1e
.byte	$d8,$17,$08,$17,$00,$0f
.byte	$c0,$18,rst_sprite2,$00
sprite1clr:
.byte	$f4,$fa									// Multicolor colors
.byte	$fb,$f1,$fe,$fe,$fe,$fb,$fb,$f9			// Sprite colors
sprite1def:
.byte   $ff,sprbs,sprbs+1,sprbs+2,sprbs+3,sprblock/$40,sprblock/$40,$00


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
	sta $d001
	sta $d003		
	lda #$33
	sta $d005
	sta $d007
	sta $d009		
	lda #$41
	sta $d00b
	sta $d00d
	lda #$7c
	sta $d01b
	// Update definitons
	lda #sprblock/$40
	sta $47fd
	sta $47fe
	lda #$63
	sta $d01d
	sta $d017
	lda #$c3
	sta $d010	
	// Line 48	
	lda #sprbs+6
	sta $07fc	
	lda lox
	and #$07
	ora #$e0
	sta $d000
	eor #[$50^$e0]
	sta $d002	
	pla
	cli
	rti
	
	
// *********************
// Second sprite manager
// *********************
irq_sprite3:	
	pha
	// Line 52
	lda #$e1
	sta $07fb
	lda #$e0
	sta $07fa	
	lda #$92
	sta $dd00
	lda #$c8
	sta $d016
	lda #$fc
	sta $d01c
	lda #rst_stable
	sta $d012
	lda #<irq_stable1
	sta $fffe
	lda #>irq_stable1
	sta $ffff	
	lsr $d019	
	pla
	rti
		
		
		
		
irq_stable1:
	pha					// 3+9+0/7
	sec					// 2
	lda #$31			// 2
	sbc $dc04			// 4
	sta *+4
	bpl *
	.fill $06,LDA_IMM	
	.byte BIT_ZP
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
	sta $d028			// 4
	lda #bgcolor		// 2
	sta $d027			// 4		
	.fill 7,NOP			// 16
	lsr $d016			// 6
	stx $d016			// 4		
	bit $ea				// 3		
	nop
	logoloop:		
		nop
		sta $d028			// 4	
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
		sta $fff0			// 4
		lda.a scrollcolor	// 4
		sta $d028			// 4
		lda #bgcolor		// 2
		sta $d027			// 4
		.fill 2,NOP			// 4
		lsr $d016			// 6
		stx $d016			// 4		
		dey					// 2
		bpl logoloop		// 3
				
	!:
	lda #$93
	sta $dd00
	nop
	lda #$1e
	sta $d011	
	lda #$18
	sta $d018
	lda #$d8
	sta $d016		
	
	nop
	nop
	lda #$ff
	sta $d01c
	
	lda #$33+63
	sta $d005
	sta $d007
	sta $d009
	lda #$41+42
	sta $d00d
	
	nop	
	ldy #$3b
!:
	dey	
	bne !-
	
	
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
	dex
	cpx #$c8
	bcs !+
	inc hix
	ldx #$cf
!:
	stx lox	

	ldx savex
	ldy savey
	lda #ORANGE
	sta $d021
	lda #rst_mdlswitch-1	// 2
	sta $d012				// 4
	lda #<irq_switch		// 2
	sta $fffe				// 4
	lda #>irq_switch		// 2
	sta $ffff				// 4	
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
.fill 20,[[[[19-i]*2]+8]&6]+[[i&1]*$40]+$18+1

.align $0020
.print "D018 table: "+toHexString(*)
d018table:
.fill 20,$10+[i&$f]

.align $0020
.print "Low port table: "+toHexString(*)
loporttable:
.byte $3f,$3f
.byte $05,$07,$09				// Block plex
.byte $3f,$3f			// Second plex
.byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
.byte $05,$07,$09			// First plex
.byte $3f
.align $0020
.print "High port table: "+toHexString(*)
hiporttable:
.byte $d0,$d0
.byte $d0,$d0,$d0
.byte $d0,$d0
.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
.byte $d0,$d0,$d0
.byte $d0

.align $0020
.print "I/O value table: "+toHexString(*)
iovaltable:
.byte $d0,$d0
.byte $33+42
.byte $33+42
.byte $33+42
.byte $d0,$d0
.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
.byte $33+21
.byte $33+21
.byte $33+21
.byte $d0

.align $0020
.print "Realign: "+toHexString(*)
realign:
.fill 13,$18+[[i+7]&7]

.align $0040
sprblock:
.fill $40,$aa
