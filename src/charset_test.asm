:BasicUpstart2(codexx)

codexx:
        cli

        lda #$18
        sta $d018

        ldy #0
!:
        lda charpiu,y
        //sta charset+[38]*8,y
        iny
        cpy #8
        bne !-

        ldx #0
!:
        txa
        sta $0400,x
        inx
        bne !-

        jmp *


.align 8
charpiu:
.byte %00000000
.byte %00000000
.byte %00000000
.byte $ff
.byte %00000000
.byte %00000000
.byte %00000000


.pc = $2000 "Charset"				// Elder
charset:
.import binary "data/charset.raw"
