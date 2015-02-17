.align $40
stabilizer_irq_pal:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #<stabilized_irq
        sta $fffe

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

        inc $d020
        .fill $10,NOP
        dec $d020


        jmp bitmap_split_irq
