.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

.const	freshcode	=	$fa00		// Fresh's code real address
.const	sprblock0	=	$0100		// Reloc'ed sprite def
.const	colour_ram 	= 	$2800
.const	colorbase 	= 	$2800

.pc = $0440 "Main code"
code:
		sei
		lda #$da
		sta startlogo+1
		lda #$60
		sta startlogo
		.if(PLAY_MUSIC){
			lda #0
			sta $d015
			sta $d011
			sta $d020
			sta text_delay
			sta page_pt
			jsr reset_writer_pointers
			jsr music.init
		}

		:kernal_off()
		:turn_off_cia_turn_on_raster_irq()
		//:kill_nmi()

		//:d011($00)			// Freshness - already 0
        jsr copyfppcode		// Freshness
		jsr initscroll		// Freshness
		jsr clear_text_screen
		:wait_frame()		// Needed by next part

		jsr start_timer	// Freshness
		//:d011($3b)
		:d012($f9)
		:set_irq(msx_irq)
		//jsr restorefppmem

		cli
		jmp *

.pc = * "Functions 2"
.import source "functions_2.asm"

// *SPAZIO* Qua abbiamo ancora 30 byte

.pc = $4400 "Text"
.import source "data/text.asm"

.pc=$540 "Screen LUT"
.import binary "data/screen.raw"
colortab:
.byte	$0e,$0e,$04,$0b,$06,$00,$00,$06,$8b,$84,$8c,$83,$8d,$81,$81,$81	// Used by fade

.pc = $0800 "Sideborder sprites"	// Elder
sideborder_sprites:
.import binary "data/sideborder_sprites.raw"

.pc = $0a00 "Top sprites"			// Fresh
b0sprite:
.import binary "data\top_sprites.prg"

.pc = $0e00 "Logo data"				// Fresh
logo:
.import source "logoparser.asm"

.pc = $2000 "Charset"				// Elder
.import binary "data/charset.raw"

.pc = $21c0 "Lower border sprites"	// Elder
lower_border_sprites:
.import binary "data/lower_border_sprites.raw"

.pc = $2300 "Bottom sprites"		// Elder
bottom_sprites:
.import binary "data/sprit.raw"

.pc = * "Functions 3"
.import source "function3.asm"		// Fresh+Elder

.pc = $2880 "D800 table"			// Fresh+Elder
.import binary "data/d800_comp.raw"

.pc = $2a00 "Pixels"				// Elder+Fresh
.import binary "data/pixels.raw"

.pc = $3680 "Elder's code"
.import source "sideborder_pal.asm"
.pc = * "Bottom IRQs"
.import source "bottom_irqs.asm"
.pc = * "Text writer"
.import source "text_writer.asm"

// *SPAZIO* Qua abbiamo ancora 7 bytes

.pc = $3a00  "Elder's functions"
.pseudopc freshcode
{
.fill $40,0						// <-- Mandatory!!
.import source "functions.asm"	// Max size $C0
// *SPAZIO* Qua abbiamo 44 byte
}

.pc = $3b00 "logo swinger"
.pseudopc freshcode+$100
{
.import source "top_sprite_routine.asm"
.import source "timer.asm"
}
.pc=* "End of code Fresh's code"
