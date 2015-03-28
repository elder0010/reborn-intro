// Copy FPP code high memory (F700)
copyfppcode:
		ldx #$00
     !:
		.for(var i=0;i<5;i++) {
			lda $3b00+i*$100,x
        	sta freshcode+i*$100,x
        }
		lda #$00
		//sta $3a00,x			// Attenzione, coccia con la roba di Elder
		sta $3b00,x
		sta $3c00,x
		sta $3d00,x
		sta $3e00,x
		sta $3f00,x
        dex
        bne !-
        rts

clone_screen_1_to_0:
        ldx #0
!:
        lda $0600,x
        sta $0200,x
        dex
        bne !-
        rts

position_first_sprites_line:
        lda #0
        sta plex_ct
        sta $d025

        lda #ORANGE
        sta $d026

        jsr next_bottom_sprites
        jsr recolour_sprites

        :point_next_sprites([bottom_sprites/$40],screen_0)
        :point_next_sprites([bottom_sprites/$40]+7,screen_1)

        inc plex_ct

        lda #<[$b0+6*24]
        ldx #14
!:
        sta $d000,x
        sec
        sbc #24
        dex
        dex
        bne !-
		stx $d01b

        lda #$e0
        sta $d010

        lda #$ff
        sta $d01c
        sta $d015

        rts

next_bottom_sprites:

        //Sprites Y & PT
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

recolour_sprites:

        ldx #7
        lda #BROWN
!:
        sta $d028,x
        dex
        bpl !-
        rts
