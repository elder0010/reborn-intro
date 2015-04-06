.align $4
bottom_sprites_y:
.const base_y =  $bb
.for(var y=0;y<3;y++){
    .byte base_y+[y*21]
}


position_sideborder_sprites:
		.const base_sideborder = $0
		.const base_y_sideborder = $76

		.for(var i=0;i<7;i++) {
			lda #[sideborder_sprites/$40]+i
			sta screen_0+$03f9+i
		}

        lda #$ba
        sta $d010

        lda #base_sideborder-32
        sta $d002
        sta $d00a

        lda #base_sideborder
        sta $d004
        sta $d00c
		sta $d01d
		sta $d017

        lda #$58
        sta $d006
        sta $d00e

        lda #$58+24
        sta $d008

        lda #BLACK
        sta $d025

        lda #LIGHT_GRAY
        sta $d026

        lda #LIGHT_BLUE
        sta $d028
        sta $d02d

        lda #LIGHT_RED
        sta $d02a
        sta $d02b
        sta $d02e

        lda #base_y_sideborder
        sta $d003

		lda #$ff
		sta $d01c
		rts
		
		
next_bottom_sprites:
        //Sprites Y & PT
		stx $d018
        ldy plex_ct
        lda bottom_sprites_y,y
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f		
        rts

// Copy FPP code high memory (F700)
copyfppcode:
		ldy #$00
		sty cptr
		sty cptr+2
		lda #$3a
		sta	cptr+1
		lda #>freshcode
		sta cptr+3
!:
		lda (cptr),y
		sta (cptr+2),y
		lda #$00
		sta (cptr),y
		dey
		bne !-
		inc cptr+1
		inc cptr+3
		bne !-
		rts		
		


