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

sprite_line_pt:
.byte 0




//per line
bottom_sprites_pt_offset:
.byte 0,7

.align 6
bottom_sprites_y:
.const base_y =  $bb
.for(var y=0;y<4;y++){
    .byte base_y+[y*21]
}


.align 12
d025_colours:
//.byte $f4,$f0,$f0,$f0,$f6
.byte $f0,$f0,$f0,$f6

d026_colours:
//.byte $f4,$fa,$ff,$f8,$f8
.byte ORANGE,ORANGE,$f8,$f8
