// ************************
// Ons Logo FPP - Freshness
// ************************

// Useful routines:
// - initscroll: this must be called before everything else to prepare tables (at least before IRQs)
// - set_mdlirq: this must be called every frame in the last irq handler before this effect (it sets next irq handler)
// - setscrollcolor: this can be called whenever needed (A = Scroll color)
// - restorefppmem: this must be called at the end of the intro to restore bank 1 memory

// Linking:
// These are the things that need to be modified for linking:
// - rst_next: next raster line IRQ (after this effect)
// - next_irq: next raster IRQ handler (happening at rst_next)
// - bmp_switch: routine for handling bitmap and sideborder


// Switching rasters
// *****************
.const	rst_sprite1		=	$12c		// Top sprites
.const	rst_sprite2		=	$30			// More sprites
.const	rst_sprite3		=	$35			// More sprites
.const	rst_next		=	$c1			// Next raster IRQ

// Zero page variables
// *******************
.const	savex		=	$c0			// Save x inside IRQ handler
.const	savey		=	$c1			// Save y inside IRQ handler
.const	lox			=	$c2			// D016 current value (C8-CF)
.const	hix			=	$c3			// Upper scroll position
.const	movpos		=	$c4			// Current scroll index position
.const	scrollcolor	=	$c5			// Logo color
.const	ptr			=	$c6			// Misc 16 bit pointer
.const	ptr2		=	$c8			// Misc 16 bit pointer
.const	ptr3		=	$ca			// Misc 16 bit pointer
.const	temp		=	$cc			// Misc 8 bit temporary data
.const	temp2		=	$cd			// Misc 8 bit temporary data
.const	dummy		=	$ce			// Dummy byte for timing
.const	spr			=	$cf			// Sprites definitions (2 bytes)
.const	direction	=	$d0			// Sprites definitions (2 bytes)
.const	sb0			=	$b0
.const	sb1			=	$b1
.const	sb2			=	$b2
.const	sb3			=	$b3
.const	sb4			=	$b4
.const	sb5			=	$b5

// Colors
// ******
.const	d800scr		=	LIGHT_GREY
.const	bgcolor		=	LIGHT_GREY	// MUST Be >=8!!!

// Pointers
// ********
.const	savesprite	=	$f000		// Save bank 1 sprite definition RAM
.const	savecfpp	=	$f400		// Save bank 1 FPP char definition RAM
.const	logoswap	=	$f800		// Swapped nibble for sprites
.const	saveline6	=	$fa00		// Save bank 1 line 6 of 1st char definition (needed for blanking bank swap)
// Bank 0
.const	fppcharscreen	=	$0400	// FPP data row
// Bank 1
.const	logofpp		=	$4007		// FPP starting position (Last line FPP)
.const	b1sprite	=	$7c00		// Bank 1 sprite base
.const	sprblock	=	$7f00		// Filled block sprite
.const	sbleft		=	$7f40		// Sideborder sprite left
.const	sbright		=	$7f80		// Sideborder sprite right

// External routine (Test only)
// ****************************
.const	bmpswitch 	=	stabilized_sideborder_routine		// Routine to call for bmp + sideborder
.const	next_irq	=	lower_split_irq						// Next irq handler (after this effect)

// Sprite def.
// ***********
.function def(area) {
	.return floor([area&$3fff]/$40)
}


// FPP Precalc'd tables
// ********************

// D018: create d018 list for next use
.var	fpplines=List()
.eval	fpplines.add(0,1,2,3,4,5,6,7,7,7,7,7,8,9,10,11,12,13,14,15)
.var	d018values=List()
.for(var i=0;i<39;i++)
	.eval	d018values.add([[$f+fpplines.get(floor([i+1]/2))]&$f]+[16*[[floor([i+4]/21)*2+5]&$7]])

// D018: change gfx (even)
.print "D018 table: "+toHexString(*)
d018table:
.fill 19,d018values.get([18-i]*2+1)


// Plexer
// ******
// Value modified on each FPP line (used for multiplexing sprites)

// D0xx ports
.print "Plex on FPP tables [$80]: "+toHexString(*)
plexport:
.byte	$40+$3f,$40+$3f,$40+$3f,$40+$3f,$40+$0b,$40+$0d,$40+$3f,$40+$3f,$09,$07,$05,$3f,$40+$3f,$40+$3f,$40+$3f,$40+$3f,$40+$3f,$40+$09,$40+$07,$40+$05

// Values to be assigned
plexvalue:
.byte	$1e,$33,$33,$33,$36+42,$36+42,$33+42,$33+42,$33+42,$33+42,$33+42,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21,$33+21

masks:
.byte	$00,$03,$07,$0f

// Sprite definitions
// ******************
// To be copied on second bank
spritedef:
.byte	def(sprblock),def(sprblock),def(b1sprite)+0,def(b1sprite)+1,def(b1sprite)+2,def(sbleft),def(sbright)
.byte	def(sprblock),def(sprblock),def(b1sprite)+3,def(b1sprite)+4,def(b1sprite)+5,def(sbleft),def(sbright)
.byte	def(sprblock),def(sprblock),def(b1sprite)+6,def(b1sprite)+8,def(b1sprite)+9,def(sbleft),def(sbright)

// VIC configuration at raster 0
sprite1tbl:
.byte	$d8,$15,$08,$15,$38,$1e,$68,$1e					// Sprites (0-3) coordinates
.byte	$80,$1e,$00,$09,$78,$09,$38,$60					// Sprites (4-7) coordinates
.byte	$02,$18,rst_sprite2,$00,$00,$ff					// D010 - D015
.byte	$c8,$03,$1e,$01,$01,$00,$ff,$03,$00,$00  		// D016 - D01F
.byte	LIGHT_GREY,LIGHT_GREY,bgcolor,bgcolor,bgcolor	// Border/Background colors
.byte	$f4,$fa											// Multicolor sprite colors
.byte	$fb,$fb,$fe,$fe,$fe,0,$f1,GREY					// Sprite colors
sprite1def:	// Sprite definitions
.byte   def(sprblock0),def(sprblock0),def(b0sprite)+1,def(b0sprite)+2,def(b0sprite)+3,def(b0sprite),def(b0sprite),def(b0sprite)+14


// Logo positions (a quarter)
// **************************
movement:
.fill	65,floor(30.4*sin(i*PI/128))

// Save stuff
// **********
savestuff:			// Sprites
	lda #>b1sprite
	ldx #>savesprite
	bne !+
loadstuff:
	ldx #>b1sprite
	lda #>savesprite
!:
	ror direction	// Set/Clear carry according to data direction
	sta ptr+1
	stx ptr+3
	ldy #>b0sprite+[4*$40]
	sty ptr+5
	ldy #$00
	sty ptr
	sty ptr+2
	sty ptr+4
	ldx #$04
!:
	lda (ptr),y
	sta (ptr2),y
	lda (ptr3),y
	sta (ptr),y
	dey
	bne !-
	inc ptr+1
	inc ptr+3
	inc ptr+5
	dex
	bne !-
	rts


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
quitirq:
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
	lda #$3f
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
	eor #[$c8^$e0]
	sta $d00a
	eor #[$e0^$58]
	sta $d00c
	lda scrollcolor
	nop
	sta $d02c
	lda #def(b0sprite)+4
	sta $07fa
	lda #def(b0sprite)+5
	sta $07fb
	lda #def(b0sprite)+6
	sta $07fc
	lda #def(b0sprite)+11
	sta $07fd
	pla
	rti


// *********************
// Second sprite manager
// *********************
irq_sprite3:
	pha
	sty savey
	sec
	lda #$2e
	sbc $dc04
	sta *+4
	bpl *
	.byte	LDA_IMM,LDA_IMM,LDA_IMM,LDA_IMM,LDA_IMM,LDA_IMM,BIT_ZP,NOP
	lda #$5e
	ldy #def(b0sprite)+10
	sta $d018-[def(b0sprite)+10],y
	sta $dd00
	stx savex
	ldx lox
	stx loxabs+1		// 4
	sty $07fa
	lda #def(b0sprite)+12
	sta $07fb
	lda #def(b0sprite)+13
	sta $07fc
	lda #def(b0sprite)+15
	sta $07fe
	lda #$1f
	sta $d01c
	ldy #19				// 2
	lda #$19			// 2
jmptest:
	bne logo_start		// 4 Page cross


// Copy sprite pointers
// ********************
copydef:
	ldx #$06
cpdef:
	ldy #$08
!:
	lda $57f8,x
	rol
	rol spritedef+$00,x
	rol $57f8,x
	lda $5ff8,x
	rol
	rol spritedef+$07,x
	rol $5ff8,x
	lda $47f8,x
	rol
	rol spritedef+$0e,x
	rol $47f8,x
	dey
	bne !-
	dex
	bpl cpdef
	rts


.align	$0100
// Main FPP Code
// *************
	skipper:
		bne sprcol
	logoloop_pos:	// Do FPP and plex sprites
		sta $d02d			// 4
		lda scrollcolor		// 3
		sta $d02c			// 4
		lda d018table,y		// 4
		sta $d018			// 4
		txa					// 2
		anc #$40			// 2
		eor $d011			// 4
		adc #$02			// 2
		and #$47			// 2
	loxabs:
		ldx #$00			// 2
	logo_start:
		lsr $d016			// 6
		sta $d011			// 4
		stx $d016			// 4
		ldx plexport,y		// 4
		lda plexvalue,y		// 4
		sta $d000,x			// 5
		cpy #$00			// 2 Special case for sprite definitions
		bne skipper			// 3
		sta $d018			// 4
	sprcol:
		lda scrollcolor		// 4
		sta $d02d			// 4
		lda #bgcolor		// 2
		sta $d02c			// 4
		lsr $d016			// 6
		sta $d016			// 4
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
	lda #$c3
	sta $d01d
	nop
	sax $d017
	lda #$50
	sta $d00a
	lda #$68
	sta $d00c
	lda #$d8
	sta $d016
	lda #$3f
	sta $d01c
	lda #$72
	sax $d010
	lda #$76		// These are needed for next part
	sta $d005		//
	sta $d007		//
	sta $d009		//
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
		cpy #$03
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
	sta $d011-12,y
	lda #rst_next			// 2
	sta $d012-12,y			// 5
	lda #<next_irq			// 2
	sta $fffe				// 4
	lda #>next_irq			// 2
	sta $ffff				// 4
	jsr bmpswitch
	lsr $d019
	cli

	inc movpos	// Next logo position
	lda movpos	// Manage 2�/4� sector
	bit movpos
	anc #$3f	// AND + clear carry
	bvc !+
	eor #$3f
	adc #$01	// Carry always cleared after this
!:
	tay
	lda movement,y
	bit movpos	// Manage 3�/4� sector
	bpl !+
	eor #$ff
	adc #$01
!:
	tax
	ldy #$02
!:
	anc #$fe	// Carry cleared
	ror
	dey
	bpl	!-
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
	tax
	lda #$1f
	sax sb0
	inx
	sax sb1
	inx
	sax sb2
	axs #[$100-$15]
	sax sb3
	inx
	sax sb4
	inx
	sax sb5
	ldx #60

spcprloop:
	ldy sb5
	lda (ptr),y
	sta sbright-1,x
	ldy sb2
	lda (ptr),y
	sta sbleft-1,x
	ldy sb4
	lda (ptr),y
	sta sbright-2,x
	ldy sb1
	lda (ptr),y
	sta sbleft-2,x
	ldy sb3
	lda (ptr),y
	sta sbright-3,x
	ldy sb0
	lda (ptr),y
lftmask:
	and #$00
	sta sbleft-3,x

	cpx #[10*3]
	bcc contlogo
	cpx #[14*3]
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
	txa
	axs #3
	bne spcprloop

	// Charscreen copy
	// ***************
	lda hix
	ldx #39
	clc
!:
	sbc #$80
	anc #$3f
	ora #$40
	sta fppcharscreen,x
	dex
	bpl !-
	ldy savey
	jmp quitirq





// *********************
// Scroll initialization
// *********************

initscroll:
	clc
	jsr savestuff		// Save RAM for bank 1 sprites
	jsr buildfpp		// Build char FPP (and save RAM)

// Prepare D800
// ************

	lda #>colorbase
	sta ptr+1
	ldx #$00
	stx ptr				// Colorbase must be aligned
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


// Prepare first line
// ******************
	ldx #$3f
	lda #$aa
!:
	sta sprblock,x
	sta sprblock0,x
	dex
	bpl !-
	lda #$c8
	sta lox


// Copy logoswap
// *************
copylogo:
	ldx #$20		// Create swapped nibbles table for sideborder sprites
	ldy #$10
swapsrc1:
	lda logo-1,x
	asl
	asl
	asl
	asl
	sta temp2
	lda #$1f
	axs #[$100-1]
swapsrc2:
	lda logo-1,x
	lsr
	lsr
	lsr
	lsr
	ora temp2
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
	sty $7fff
	jsr	copydef			// Copy sprite pointers

	lda #d800scr

// Set scroll color
// ****************
setscrollcolor:
	ldx #$27
!:
	sta $d800,x
	dex
	bpl !-
	sta scrollcolor
	rts


// Build FPP logo
// **************
buildfpp:
	lda #<logofpp	// Prepare char definitions
	sta ptr
	lda #>logofpp
	sta ptr+1
	lda #>savecfpp
	sta ptr2+1
	ldy #$00
	sty ptr2		// Must be $100 aligned
	ldx #$00
rowloop:
	lda logo,x		// Load "compressed" byte
	sta temp2		// Store in temp
doublechar:
	lda #$01		// Set exit condition
bitloop:
	asl temp2		// Get bit
	php
	rol				// Stuff it once
	plp
	rol				// Stuff it twice
	bcc bitloop		// Loop 4 times (1->4->10->40->C)

	bit direction
	bmi rlresume
	pha
	lda (ptr),y
	sta (ptr2),y
	pla
	.byte BIT_ABS
rlresume:
	lda (ptr2),y
	sta (ptr),y
	tya
	adc #$07		// Carry always set => +8
	tay
	and #$08		// If (y&8) then
	bne doublechar	// we need to compute the low nibble of temp
	inx				// Ok, next byte
	bcc rowloop		// Till we need to change destination page
	bne !+			// End of source page?
	lda rowloop+2
	eor #$01
	sta rowloop+2
!:
	inc ptr2
	lda ptr2
	and #$08
	beq !+
	lda #$00
	sta ptr2
	inc ptr2+1
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

// Clear line 5/6 of first definition ($D018 <= $xe)
// *************************************************
saveline6rnt:
	ldx #$06
	ldy #$40
s6loop:
	lda saveline6-1,y
	bit direction
	bmi s62
s61:
	lda $7a00,x
	sta saveline6-1,y
	lda #$00
s62:
	sta $7a00,x
	dey
	txa
	axs #[$100-$8]
	bcc s6loop
	lda s61+2
	eor #$01
	sta s61+2
	sta s62+2
	lsr
	bcs s6loop
testjsr:				// Removable label (test purpose only)
	rts


// Restore old values
// ******************
restorefppmem:
	sec
	jsr loadstuff
	jsr copydef
	jmp buildfpp
