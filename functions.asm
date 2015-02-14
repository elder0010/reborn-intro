


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

        //ora copio il char nella zona a dx
        lda #0
        ldx #$13
        lda #0
        .const bb = 17
!:
        sta screen_0+[[bb+1]*$28],x
        sta screen_0+[[bb+2]*$28],x
        sta screen_0+[[bb+3]*$28],x
        sta screen_0+[[bb+4]*$28],x
        sta screen_0+[[bb+5]*$28],x
        sta screen_0+[[bb+6]*$28],x
        sta screen_0+[[bb+7]*$28],x

        sta screen_1+[[bb+1]*$28],x
        sta screen_1+[[bb+2]*$28],x
        sta screen_1+[[bb+3]*$28],x
        sta screen_1+[[bb+4]*$28],x
        sta screen_1+[[bb+5]*$28],x
        sta screen_1+[[bb+6]*$28],x
        sta screen_1+[[bb+7]*$28],x

        inx
        cpx #$28
        bne !-

        rts

prepare_cover_sprites:

        lda #$ff
        ldx #$40
!:
        sta [bottom_sprites+$40*21],x
        dex
        bpl !-
        rts
