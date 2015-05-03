movegame:		
		sta $a000
		ldx #[relocendmovegame-relocmovegame-1]
	!:
		lda relocmovegame,x
		sta $0100,x
		dex
		bpl !-
		jmp $0100

// Move game data
relocmovegame:
		php
		sei
		ldx $01
		lda #$34
		sta $01
		lda #$40
		sta $fb
		lda #$08
		sta $fd
		ldy #$00
		sty $fa
		sty $fc
	!:
		lda ($fa),y
		sta ($fc),y
		dey
		bne !-
		inc $fb
		inc $fd
		bne !-
		stx $01
		plp
testloop:
		jmp cmdLineVars.get("gamestart").asNumber()	// Here we need to put the jmp to the game decompressor
relocendmovegame:				

