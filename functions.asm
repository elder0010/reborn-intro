copy_screendata:

        ldx #0
!:
        lda screendata
        sta screen_0,x

        lda screendata+$100,x
        sta screen_0+$100,x

        lda screendata+$200,x
        sta screen_0+$200,x

        lda screendata+$300,x
        sta screen_0+$300,x
        dex
        bne !-

        rts

prepare_chars_under_sprites:

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

        lda #0
        sta bottom_fake_charset+16 //Azzero l'ultima riga o si vede il glitch :(

        //ora copio il char nella zona a dx
        ldx #$13
        lda #0
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
    //    sta screen_1+[[bb+5]*$28],x
    //    sta screen_1+[[bb+6]*$28],x
    //    sta screen_1+[[bb+7]*$28],x

        inx
        cpx #$28
        bne !-

        lda #$01
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
        .pc = * "debug"
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



.align 6
bottom_sprites_y:
.const base_y =  $bb
.for(var y=0;y<4;y++){
    .byte base_y+[y*21]
}
