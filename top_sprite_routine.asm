//Freshness

// Switching rasters
// *****************
.const	rst_setsprite	=	$2e			// Set logo sprites
.const	rst_stable		=	$30+8		// Stable irq
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
	lda #$ff
	ldx #$3e
!:
	sta $7fc0,x
	sta $3fc0
	dex
	bne !-
	lda #bgcolor
	sta $d021
	lda #$ff
	sta $d015
	rts

set_mdlirq:
	lda #$30
	sta $d012
	lda #$98
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
	lda #$ff
	sta $d01c
	lda #<irq_setsprite
	sta $fffe
	lda #>irq_setsprite
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
.byte	$c0,$18,[rst_setsprite-2],$00
sprite1clr:
.byte	$f4,$fa									// Multicolor colors
.byte	$fb,$f1,$fe,$fe,$fe,$fb,$fb,$f9			// Sprite colors
sprite1def:
.byte   $ff,sprbs,sprbs+1,sprbs+2,sprbs+3,sprblock/$40,sprblock/$40,$00


// *********************
// Second sprite manager
// *********************
	
irq_setsprite:	
	lsr $d019
	lda #rst_stable-2
	sta $d012
	lda #<irq_stable1
	sta $fffe
	lda #>irq_stable1
	sta $ffff	
	pha

	lda #$32
	sta $d003
	sta $d00f
	lda #$33
	sta $d005
	sta $d007
	sta $d009
	lda #$41
	sta $d00b
	sta $d00d
	lda #$e0
	sta $d002
	
	
	lda #$3e
	sta $d01b	
	lda #$ff
	sta $d015

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

	lda $d021
	sta $d022	
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
	stx savex				// 3
	sty savey				// 3
	lsr $d019				// 6+9+0/1
	lda #$dd
	sta $d01c
	.fill 6,NOP
	ldx.a lox				// 4	
	stx $d016				// 4	
	lda #$92				// 2
	sta $dd00				// 4		
	lda	d011table+19		// 4
	ldy #rst_stable-1		// 2
	cpy $d012				// 4 63/00
	beq !+				
!:						// 3		
	ldy #19				// 2
	jmp startfpp		// 3
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
	startfpp:
		sta $d011			// 4		
		stx $d016			// 4
		lda hiporttable,y	// 4
		sta mod_io+2		// 4		
		lda iovaltable,y	// 4
	mod_io:
		sta $fff0			// 4
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
	lda #$1e
	sta $d011
	sta $d020
	lda #$ff
	sta $d01c
	.fill 10,NOP
		
	lda #$18
	sta $d011
		
	ldy #$43
!:
	dey	
	bne !-
	nop
	nop	

	
	ldy #00
	!:	
		lda realign,y
		sta $d011		
		sta $d020
		.fill 14,NOP		
		bit $fe
		iny
		cpy #12
		bcc !-
		
	lda #$38+[[10+2]&7]	
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
	lda #ORANGE
	sta $d021
	lda #rst_mdlswitch-1	// 2
	sta $d012				// 4
	lda #<irq_switch		// 2
	sta $fffe				// 4
	lda #>irq_switch		// 2
	sta $ffff				// 4	
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
.fill 20,[[[[19-i]*2]+10]&6]+[[i&1]*$40]+$18

.align $0020
.print "D018 table: "+toHexString(*)
d018table:
.fill 20,$10+[i&$f]

.align $0020
.print "Low port table: "+toHexString(*)
loporttable:
.byte $3f,$3f
.byte $09,$0b				// Block plex
.byte $03,$05,$07			// Second plex
.byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
.byte $03,$05,$07			// First plex
.byte $3f
.align $0020
.print "High port table: "+toHexString(*)
hiporttable:
.byte $d0,$d0,$d0
.byte $d0,$d0
.byte $d0,$d0,$d0
.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
.byte $d0,$d0,$d0

.align $0020
.print "I/O value table: "+toHexString(*)
iovaltable:
.byte $d0,$d0
.byte rst_stable+42
.byte rst_stable+42
.byte rst_stable+42
.byte rst_stable+42
.byte rst_stable+42
.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
.byte rst_stable+21
.byte rst_stable+21
.byte rst_stable+21
.byte $d0

.align $0020
.print "Realign: "+toHexString(*)
realign:
.fill 12,$18+[[i+1]&7]

.align $0040
sprblock:
.fill $40,$aa
