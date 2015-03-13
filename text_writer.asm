.const row_0 = screen_0+$28*19
.const row_1 = screen_1+$28*20
.const row_2 = screen_1+$28*21
.const row_3 = screen_1+$28*22
.const row_4 = screen_0+$28*23
.const row_5 = screen_0+$28*24

.const caret_on = $22
.const caret_off = $23

clear_screen:
        lda #$22
        ldx #17
!:
        sta row_0,x
        sta row_1,x
        sta row_2,x
        sta row_3,x
        sta row_4,x
        sta row_5,x

        dex
        bpl !-

        rts

write_char:

        ldx row_pt
        lda rows_lo,x
        sta currow+1
        sta curchrow+1
        lda rows_hi,x
        sta currow+2
        sta curchrow+2

        ldx char_pt
curpage:
        lda page_0,x
currow:
        sta row_0,x

//-------------------
//Caret blink
caretsw:
        lda #0
        clc
        adc #1
        and #$f
        sta caretsw+1
        cmp #$8
        bpl !+
        lda #caret_on
        jmp storcaret
!:
        lda #caret_off
storcaret:
        inx
curchrow:
        sta $ffff,x
//-------------------

//        inc char_pt questo va messo dentro la routine che manda avanti il testo
        lda char_pt
        cmp #17
        bne noline

//next line
        lda #0
        sta char_pt
        inc row_pt

        lda row_pt
        cmp #5
        bne noline
//next page
        inc page_pt
        lda page_pt
        cmp #page_no
        bne !+
        lda #0
        sta page_pt
!:
        ldx row_pt
        lda rows_lo,x
        sta currow+1

        lda rows_hi,x
        sta currow+2
noline:
        rts


print_text:
        lda #0
        eor #$ff
        sta print_text+1
        //cmp #$4
        bne !+
    //    inc char_pt
!:
        rts


.align 10
rows_lo:
.byte <row_0,<row_1,<row_2,<row_3,<row_4
rows_hi:
.byte >row_0,>row_1,>row_2,>row_3,>row_4

.align 4
text_lo:
.byte <page_0,<page_1

text_hi:
.byte >page_0,>page_1
