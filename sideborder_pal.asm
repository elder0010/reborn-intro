.align $40
stabilizer_irq_pal:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #$3b
        sta $d011

        lda #<stabilized_irq
        sta $fffe

        inc $d012
        inc $d012

        asl $d019
        tsx

        cli

        .for(var n=0;n<32;n++){
            nop
        }

        brk


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
        ldy #5
        :wait()

        sta $d020
        sta $d021

        


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
