        inc $d020
        .fill $50,NOP
        dec $d020


next_bottom_sprites:

        lax sprite_line_pt
        clc
    //    adc #4
        cmp #8
        bne !+
        lda #0
!:
        sta sprite_line_pt


//Sprites Y & PT

        ldy #0
!:
        lda bottom_sprites_pt,x
        sta screen+$03f8,y
        inx
        iny
        cpy #7
        bne !-


        lda bottom_sprites_y

        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d


        lda #$ff
        sta $d01c

        lda #BLUE
        sta $d027

        lda d025_colours
        sta $d025

        lda d026_colours
        sta $d026

        rts

reposition_sprites_x:



        ldx #0
        lda #$ae
sprx:

        sta $d000,x
        clc
        adc #24

        inx
        inx
        cpx #8
        bne sprx

        rts




sprite_line_pt:
.byte 0


.align 24
bottom_sprites_pt:
.for(var x=0;x<21;x++){
    .byte [bottom_sprites/$40]+x
}

.align 4
bottom_sprites_y:
.const base_y = $bb
.for(var y=0;y<4;y++){
    .byte base_y+[y*24]
}

.align 24
d026_colours:
.byte $04,$00,$00,$00,$06

d025_colours:
.byte $0f,$0f,$08,$08,$04

/*
4c21
4c27

4f64
4f67

5072
5075

5162
5168

52d6
52d9
*/
