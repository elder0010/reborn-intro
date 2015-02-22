copy_screendata:

        ldx #0
!:
        lda screendata+$100,x
        sta screen_0+$100,x
    //    sta screen_1+$100,x

        lda screendata+$200,x
        sta screen_0+$200,x
    //    sta screen_1+$200,x

        lda screendata+$300,x
        sta screen_0+$300,x
    //    sta screen_1+$300,x
        dex
        bne !-

        rts


prepare_chars_under_sprites:

/*

        ldx #8
        lda #$ff
!:
        sta bottom_fake_charset,x
        dex
        bpl !-

        ldx #7
        lda #$00
!:
        sta bottom_fake_charset+8,x
        dex
        bpl !-
*/

    //    lda #0
    //    sta bottom_fake_charset+16 //Azzero l'ultima riga o si vede il glitch :(

        //ora copio il char nella zona a dx
        ldx #$12
        lda #$20
        .const bb = 17
!:
        sta screen_0+[[bb+1]*$28],x
        sta screen_0+[[bb+2]*$28],x
    //    sta screen_0+[[bb+3]*$28],x
    //    sta screen_0+[[bb+4]*$28],x
    //    sta screen_0+[[bb+5]*$28],x
        sta screen_0+[[bb+6]*$28],x
        sta screen_0+[[bb+7]*$28],x

    //    sta screen_1+[[bb+1]*$28],x
    //    sta screen_1+[[bb+2]*$28],x
        sta screen_1+[[bb+3]*$28],x
        sta screen_1+[[bb+4]*$28],x
        sta screen_1+[[bb+5]*$28],x
    //    sta screen_1+[[bb+6]*$28],x
    //    sta screen_1+[[bb+7]*$28],x

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

prepare_cover_sprites:

        lda #$aa
        ldx #$40
!:
        sta [bottom_sprites+$40*21],x
        dex
        bpl !-
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

        lda #[sideborder_sprites/$40]+0
        sta screen_0+$03f9

        lda #[sideborder_sprites/$40]+1
        sta screen_0+$03fa

        lda #[sideborder_sprites/$40]+2
        sta screen_0+$03fb

        lda #[sideborder_sprites/$40]+3
        sta screen_0+$03fc

        lda #[sideborder_sprites/$40]+4
        sta screen_0+$03fd

        lda #[sideborder_sprites/$40]+5
        sta screen_0+$03fe

        lda #[sideborder_sprites/$40]+6
        sta screen_0+$03ff

        lda #0
        sta $d010

        lda #$50+24
        sta $d002

        lda #$50+24*2
        sta $d004

        lda #$50+24*3
        sta $d006

        lda #$50+24*4
        sta $d008

        lda #$50+24*5
        sta $d00a

        lda #$50+24*6
        sta $d00c

        lda #$50+24*7
        sta $d00e


.const base_y_sideborder = $76

        lda #base_y_sideborder
        sta $d003
        sta $d005
        sta $d007
        sta $d009

        lda #base_y_sideborder+21
        sta $d00b
        sta $d00d
        sta $d00f

        lda #0
        sta $d01d

        rts

position_first_sprites_line:
        lda #0
        sta plex_ct
        sta $d01d

        jsr next_bottom_sprites
        jsr recolour_sprites

        :point_next_sprites([bottom_sprites/$40],screen_0)

        :point_next_sprites([bottom_sprites/$40]+7,screen_1)

        inc plex_ct

        lda #$b0
        ldx #0
        !:
        sta $d002,x
        clc
        adc #24
        inx
        inx
        cpx #14
        bne !-

        lda #$e0
        sta $d010

        lda #$ff
        sta $d01c
        sta $d015

        lda #$f0
        sta $d025

        lda #ORANGE
        sta $d026
        rts
