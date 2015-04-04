.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

.const	freshcode	=	$fa00		// Fresh's code real address
.const	sprblock0	=	$0100		// Reloc'ed sprite def
.const	colour_ram 	= 	$0240
.const	colorbase 	= 	$0240

.pc = $02C0 "D800 table"			// Fresh+Elder
.import binary "data/d800_comp.raw"

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

		jsr copyfppcode		// Freshness
		jsr initscroll		// Freshness
		jsr copylut			// Freshness
		jsr clear_text_screen
		:wait_frame()		// Needed by next part

		jsr start_timer		// Freshness
		:d011($7b)			// Illegal mode
		:d012($cf)
		:set_irq(plex_0_irq)
		//jsr restorefppmem

		cli
		jmp *

.pc = * "Functions 2"
.import source "functions_2.asm"

// *SPAZIO* Qua abbiamo ancora 41 byte

.pc=$540 "Screen LUT"
.import binary "data/screen.raw"

.function fade(priority,color) {
	.return floor(<[[priority*$80]+[color&$f]])
}

colortab:
.byte	fade(0,LIGHT_BLUE),fade(0,LIGHT_BLUE),fade(0,PURPLE),fade(0,DARK_GREY),fade(0,BLUE),fade(0,BLACK),fade(0,BLACK),fade(0,BLUE)
.byte	fade(1,DARK_GREY),fade(1,PURPLE),fade(1,GREY),fade(1,CYAN),fade(1,LIGHT_GREEN),fade(1,WHITE),fade(1,WHITE),fade(1,WHITE)

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
.import source "functions_3.asm"	// Fresh+Elder

.pc = * "Text"
.import source "data/text.asm"		// Max $18A bytes

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
.import source "functions_1.asm"	// Max size $C0
// *SPAZIO* Qua abbiamo 44 byte
}

.pc = $3b00 "logo swinger"
.pseudopc freshcode+$100
{
.import source "top_sprite_routine.asm"
.import source "timer.asm"
}
.pc=* "End of code Fresh's code"
