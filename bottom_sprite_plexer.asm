next_bottom_sprites:

//Sprites Y & PT
        ldy plex_ct


        lda bottom_sprites_y,y
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

    


        lda bottom_sprites_pt_base,y
!:
        sta screen_0+$03f8,y
        clc
        adc #1
        iny
        cpy #8
        bne !-

        lda #$ff
        sta $d01c




        rts


recolour_sprites:

ldx #8
!:
lda d027_colours,x
sta $d027,x
dex
bpl !-


        rts

reposition_sprites_x:

.const base_x = $b0

        ldx #0
        lda #base_x
sprx:

        sta $d000,x
        clc
        adc #24

        inx
        inx
        cpx #16
        bne sprx

        lda #$f0
        sta $d010


        rts




sprite_line_pt:
.byte 0


.align 24
bottom_sprites_pt_base:
.for(var x=0;x<6;x++){
    .byte [bottom_sprites/$40]+[x*7]
}


.align 6
bottom_sprites_y:
.const base_y =  $bc
.for(var y=0;y<6;y++){
    .byte base_y+[y*26]
}

.align 12
d025_colours:
//.byte $f4,$f0,$f0,$f0,$f6
.byte $f0,$f0,$f0,$f6

d026_colours:
//.byte $f4,$fa,$ff,$f8,$f8
.byte ORANGE,ORANGE,$f8,$f8

.align $24
d027_colours:
.byte BROWN,BROWN,BROWN,BROWN,BROWN,BROWN,BROWN,BROWN
.byte BROWN,BROWN,BROWN,BROWN,BROWN,BROWN,BROWN,BROWN
