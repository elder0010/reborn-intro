.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

.const	sprblock0	=	$0100		// Filled block sprite
.const	sprspecial	=	$0140		// Filled block sprite
.const	freshcode	=	$fb00		// Fresh's code real address

.pc = $8000 "code"
code:
		sei
		.if(PLAY_MUSIC){
			lda #0
			sta $d015
			sta $d011
			sta text_delay
			sta page_pt
			jsr reset_writer_pointers
			jsr music.init
		}

		:kernal_off()
		:turn_off_cia_turn_on_raster_irq()
		:kill_nmi()

		lda #border_colour
		sta $d020
		//sta $d021
		//:bank_0()

		//jsr prepare_chars_under_sprites //da chiamare dopo copy_screen_data o rompe i dati
		//jsr fill_text_color_zone //Questo va rimosso quando avremo sistemato con fresh $d800		

		:d011($00)		// Freshness
        jsr copyfppcode	// Freshness
		jsr initscroll	// Freshness
		jsr clear_text_screen
		//:wait_frame()

		jsr start_timer	// Freshness		
		:d011($3b)
		:d012($f9)
		:set_irq(msx_irq)
		//jsr restorefppmem
		//	lsr $d019
		cli
		jmp *

.pc = * "functions 2"
.import source "functions_2.asm"

.pc = $8600 "text"
.import source "data/text.asm"



.pc=$0440
// $100 bytes free for code
.pc=$540
.import binary "data/screen.raw"

.pc = $0800 "sideborder sprites"	// Elder
sideborder_sprites:
.import binary "data/sideborder_sprites.raw"

.pc = $0a00 "Top sprites"			// Fresh
b0sprite:
.import binary "data\top_sprites.prg"

.pc = $0e00 "D800 table"			// Fresh+Elder
colour_ram:
colorbase:
.import binary "data/d800_comp.raw"

.pc = $2000 "charset"				// Elder
.import binary "data/charset.raw"

.pc = $21c0 "lower border sprites"	// Elder
lower_border_sprites:
.import binary "data/lower_border_sprites.raw"

.pc = $2300 "bottom sprites"		// Elder
bottom_sprites:
.import binary "data/sprit.raw"

.pc = $2800 "logo data"				// Fresh
logo:
.import source "logoparser.asm"

.pc = $2a00 "pixels"				// Elder+Fresh
.import binary "data/pixels.raw"

.pc = $3680 "Elder's code"
.import source "sideborder_pal.asm"
.import source "bottom_irqs.asm"
//3900-3907 e 39ff
.pc = * "text writer"
.import source "text_writer.asm"
.pc = $3a00  "end of zona franca elder"

.pc = $3a20 "functions"
.import source "functions.asm"
.pc = $3a9f "end of functions area"

.pc = $3b00
.pc = * "logo swinger"
.pseudopc freshcode
{
.import source "top_sprite_routine.asm"
.import source "timer.asm"
}
.pc=* "End of code Fresh's code"
