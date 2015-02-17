// Detect CIA
// **********
// White Flame (aka David Holz)
DetectCIA:	
	tsx
	lda #<continue
	sta $fffa
	lda #>continue
	sta $fffb
	lda #$81
	sta $dd0d
	lda #4
	sta $dd04
	lda #0
	sta $dd05
	sta CIAtype
	lda #%10011001
	sta $dd0e
	lda $dd0d
	lda $dd0d
	inc CIAtype
	jmp *
continue:
	lda $dd0d
	txs
	rts
	
// Detect video mode (PAL/NTSC)	
// ****************************
// J0x
DetectVIC:
	lda $d012
!:
	cmp $d012
	beq !-
	bmi DetectVIC
	cmp #$20
	lda #$01
	adc #$00
	and #$01
	sta videomode
	rts
	
