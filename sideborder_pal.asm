.align $100
/*
stabilizer_irq_pal:
        sta reset_a
        stx reset_x
        sty reset_y

        lda #$3b
        sta $d011

        lda #<stabilized_irq
        sta $fffe

        inc $d012

        asl $d019
        tsx

        cli

        .for(var n=0;n<12;n++){
            nop
        }

        brk
*/

.pc = * "stabilized irq pal"
stabilized_sideborder_routine:
	jsr	position_sideborder_sprites
	bit $fe

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

        ldy #$04    // 2 - poi vediamo quante linee ah ok, già fatto!!
        :decinc_brd(false)	// Ok, fin qua siamo dentro alla unrolled => non cambi nulla
//------------------------

        bne start	// 3

       start:
		  lda #bitmap_bg_colour
          sta $d021
       start_np:		  
          ldx #$d8
          dec counter	// 5 ZP!!
          beq exit		// 2/3	OK, niente, tocca buttare via del tempo in attesa di arrivare alla linea che ci serve
						// Guarda, facciamo così per buttarne via meno, o quanto meno per raggruppare il tempo buttato. Ok?
                        // Ora in exit prima di aprire il bordo dobbiamo attendere: 2+4+2+2+4+2(-1 perchè il branch costa un ciclo) =>15		
		  tya
		  and #06
		  tax
		  lda #$8b
		  sta $d009,x
		  ldx #$d8
          dey 			// 2
          beq badline	// 2/3   O BMI qua

          bit $fe

          :decinc_brd(false) // 40 cicli tra macro e macro

          bne start  	// 3

badline: // Qua gestiamo la badline normale (non plexante)

		lda #$d0			// (+1 per la beq) +2 // qui anche (+1 beq, 3 bit, 2 lda) ok? ok
//:decinc_brd(false)  // Allora qua la dec ci sta ma l'inc no, il lavoro dell'inc me lo fa la stx => quindi
        dec $d016

        stx $d016
        sta $d016-$d8,x

        stx $d016  // E poi andiamo avanti ok compilo

        ldy #$07
        bne start // 35

        //ora siamo qua e dobbiamo tornare a loopare le nonbad


        // Ok, fermiamoci qua per vedere se la bad va
        // mancano un paio di linee normali?? si! ma questi non sono 8, si ma adesso siamo allineati alla bad
        // adesso diventa più semplice ok
exit:
		bit $f3				// 3
		cmp (0,x)			// 6
		dec sprrow			// 5 (ZP) - sprrow inizializzato a 2 prima del sideborder
        beq !+				// 2/3
        lda #17				// 2 Questo valore va tarato,
        sta counter			// 3 cosè sta roba sta.a !? counter è ZP ma a noi serve waitare 4 per avere un nop dopo
// Vai!
        lda #$d0			// ah ok, scusa, errore di battitura ok ora torna :D. Vai, compila
        sta $d016
        stx $d016 			// "Chiudo" bordo bad
        sta $d016-$d8,x		// Apro bordo bad <- QUI SEI IN BADLINE? Ok mo te lo preparo
        ldy #[sideborder_sprites/$40]+7
        sty screen_0+$03fc
        stx $d016  			// "Chiudo" bordo bad

        ldy #$07			// Qua sono 6 cicli in ritardo rispetto all'equivalente linea bad sopra
        bne start_np		// Abbiamo delle "nop" dopo start, se ne salto 2 => -4 cicli
        					// se noti nel caso precedente avevamo una nop => 2 <=> 6-4 (minghia...)

        // te faccio vede . daje
        //BAD Line ciclo 13 in poi: xxx01234567890123456789012345678901234567890 (x)->Bordo [x00112]->6 cicli liberi [233]-> 3 cicli pre sprite 4 [444556677] -> sprites

!:
        lda #border_colour
        sta $d020

        rts
        //jmp bitmap_split_irq
