/*
fill_text_color_zone:	// Questa la integriamo direttamente in colordata => Da cancellare!!
        lda #WHITE
        ldx #0
        .const bd = 19
!:
        sta $d800+[bd*$28],x
        sta $d800+[[bd+1]*$28],x
        sta $d800+[[bd+2]*$28],x
        sta $d800+[[bd+3]*$28],x
        sta $d800+[[bd+4]*$28],x
        sta $d800+[[bd+5]*$28],x

        inx
        cpx #$12
        bne !-
        rts
*/

/*
prepare_chars_under_sprites:

        //ora copio il char nella zona a dx
        ldx #$12
        lda #$20
        .const bb = 17
!:
        sta screen_0+[[bb+1]*$28],x
        sta screen_0+[[bb+2]*$28],x
        sta screen_0+[[bb+6]*$28],x
        sta screen_0+[[bb+7]*$28],x
        sta screen_1+[[bb+3]*$28],x
        sta screen_1+[[bb+4]*$28],x
        sta screen_1+[[bb+5]*$28],x

        inx
        cpx #$28
        bne !-

        lda #$21
        ldx #$8
!:
        sta screen_0+[[bb+7]*$28]+31,x //che tocca fa..
        dex
        bpl !-
        rts
*/

/*
prepare_cover_sprites:

        lda #$aa
        ldx #$40
!:
        sta [bottom_sprites+$40*21],x
        dex
        bpl !-
        rts
*/

clone_screen_1_to_0:
        ldx #0
!:
        lda $0600,x
        sta $0200,x
        dex
        bne !-
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


.align 4
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
