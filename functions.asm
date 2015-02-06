copy_screendata:

        ldx #0
!:
        lda screendata
        sta screen,x
        lda screendata+$100,x
        sta screen+$100,x
        lda screendata+$200,x
        sta screen+$200,x
        lda screendata+$300,x
        sta screen+$300,x
        dex
        bne !-

        rts
