.const row_0 = screen_0+$28*19
.const row_1 = screen_1+$28*20
.const row_2 = screen_1+$28*21
.const row_3 = screen_1+$28*22
.const row_4 = screen_0+$28*23
.const row_5 = screen_0+$28*24

.const caret_on = $36 //[caret-mini_charset]/$8
.const caret_off = 0
.pc=$3900-86 "Text Writer"
write_char:
        ldx row_pt
        lda rows_lo,x
        sta currow+1
        sta curchrow+1
        lda rows_hi,x
        sta currow+2
        sta curchrow+2

        ldx char_pt
        ldy text_pt
curpage:
        lda page_0,y
        sta cur_char
        bne !+
//---------------------------
//Attesa per la prox pagina
        lda #1
        sta print_text+1 //Disabilito il text writer perchè è finita la pagina
        dex
        jsr caret_blink

delay_doubler:
        lda #0
        eor #$ff
        sta delay_doubler+1

        beq pagdl
        inc page_delay
pagdl:
        lda page_delay
        cmp #page_wt_amount
        bne nonextpg

        jsr reset_writer_pointers
        jsr clear_text_screen

        lda #0
        sta print_text+1

        inc page_pt
        ldx page_pt
        cpx #page_no
        bne switchpg
        ldx #0
        stx page_pt
        stx printsw+1
        jmp switchpg
.pc = $3900 "fresh blank area"
        .fill $8,$00
.pc = $3908 "end of fresh blank area"
switchpg:
        //tax
        lda text_lo,x
        sta curpage+1

        lda text_hi,x
        sta curpage+2
nonextpg:

        jmp noline
//---------------------------
!:
        lda cur_char
        cmp #$ff
        bne !+
        dex
        jsr caret_blink
        jmp next_line
!:
currow:
        sta row_0,x
        jsr caret_blink

        lda char_pt
        cmp #15
        bne noline
//---------------------------
//next line
next_line:

        lda #0
        sta char_pt
        sta printsw+1 //reset cursor
        inc row_pt
        inc text_pt

        ldx row_pt
        lda rows_lo,x
        sta currow+1

        lda rows_hi,x
        sta currow+2
noline:
        bit print_text //jsr
endx:
        rts

caret_blink:
        lda cur_char
        cmp #$ff
        beq caretoff
        inc caretblk
		lda caretblk
		anc #$1f
		adc #$f0
		lda #caret_on
        bcs storcaret
caretoff:
        lda #caret_off
storcaret:
        nop	// INX
		cpx #16
        beq !+
curchrow:
        sta $ffff,x
!:
//-------------------
        rts

print_text:
        lda #0
        bne !+
printsw:
        lda #0
        eor #$ff
        sta printsw+1
        //cmp #$4
        bne !+
        inc char_pt
        inc text_pt
!:
        jmp check_fire_space    //dopo che il testo inizia ad essere printato si può quittare l'intro

reset_writer_pointers:
        lda #0
        sta char_pt
        sta row_pt
        sta text_pt
        sta page_delay

        rts

rows_lo:
.byte <row_0+1,<row_1+1,<row_2+1,<row_3+1,<row_4+1,<row_5+1
rows_hi:
.byte >row_0+1,>row_1+1,>row_2+1,>row_3+1,>row_4+1,>row_5+1

text_lo:
.byte <page_0,<page_1,<page_2,<page_3
text_hi:
.byte >page_0,>page_1,>page_2,>page_3

.pc=$39a8
clear_text_screen:
        lda #$0
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
!:
        rts

check_fire_space:
        lda $dc01
        and $dc00
        and #$10
        bne !-
		sei

.pc = * "press space jsr target"
		sta $d011
	    lda $a000
		sta $0102		// $102 doesn't get overwritten by reset routines
		jsr restorefppmem
        lda #$37
        sta $01
		jsr resetvic	// Valutare se mettere $ff5b
		jsr $FDA3
		jsr $FD50
		jsr $FD15
		jsr $e51b		// al posto di queste due jsr
		jsr $ff5e
		jsr $E453
		jsr $E3BF
		jsr $a644
		lda $0102
.if(cmdLineVars.get("linkgame").asNumber()==0){
        jmp testloop
}else{
		jmp movegame
}
