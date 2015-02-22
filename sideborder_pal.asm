.align $40
stabilizer_irq_pal:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #$3b
        sta $d011

        lda #<stabilized_irq
        sta $fffe

        lda #>stabilized_irq
        sta $ffff

        inc $d012
        inc $d012

        asl $d019
        tsx

        cli

        .for(var n=0;n<16;n++){
            nop
        }

        brk

.align $80
stabilized_irq:
        txs
        ldx #$8
!:
        dex
        bne !-

        bit $ea
        nop

        lda #stabilizer_irq_line+1
        cmp $d012
        beq !+
!:
        lda #bitmap_bg_colour
        ldy #7
        :wait()

        bit $24

        sta $d020
        sta $0400

.macro decinc_brd(debug){
    .if(debug){
        dec $d021
        inc $d021
    }else{
        dec $d016
        inc $d016
    }
}
//Sideborder loop

        ldy #7
        :wait()

        bit $24
        bit $24
        bit $24

        nop

        lda #$d7
        ldx #$d8

        :decinc_brd(false)
//------------------------------
        ldy #7
        :wait()

        nop
        nop
        nop

        :decinc_brd(false)
//------------------------------
        ldy #7
        :wait()

        nop
        nop
        nop

        :decinc_brd(false)
//------------------------------
        ldy #7
        :wait()

        nop
        nop
        nop

        :decinc_brd(false)
//------------------------------

        //BADLINE
        sta $d021
        stx $d021



//End of sideborder code
!:

        lda $d012

        cmp #$a0
        bne !-

        lda #border_colour
        sta $d020



        jmp bitmap_split_irq
/*

        lda reset_a
        ldx reset_x
        ldy reset_y
        rti
    */
