.import source "variables.asm"
.import source "macros.asm"
.pc=music.location "Music" .fill music.size, music.getData(i)

.const	freshcode	=	$fa00		// Fresh's code real address

.pc = $0440 "Main code"
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

		:d011($00)			// Freshness
        jsr copyfppcode		// Freshness
		jsr initscroll		// Freshness		
		jsr clear_text_screen
		:wait_frame()		// Needed by next part

		jsr start_timer	// Freshness		
		:d011($3b)
		:d012($f9)
		:set_irq(msx_irq)
		//jsr restorefppmem
		//	lsr $d019
		cli
		jmp *

.pc = * "Functions 2"
.import source "functions_2.asm"

// *SPAZIO* Qua abbiamo ancora circa 40 byte

.pc = $8000 "Text"
.import source "data/text.asm"



// $100 bytes free for code
.pc=$540 "Screen LUT"
.import binary "data/screen.raw"

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

.pc = $2800 "D800 table"			// Fresh+Elder
colour_ram:
colorbase:
sprspecial:							// Special sprite
.fill $40,$55
sprblock0:
.fill $40,$aa						// Filled block sprite
.import binary "data/d800_comp.raw"

.pc = $2a00 "Pixels"				// Elder+Fresh
.import binary "data/pixels.raw"

.pc = $3680 "Elder's code"
.import source "sideborder_pal.asm"
.import source "bottom_irqs.asm"
//3900-3907 e 39ff => Qua rivediamo alla fine per sistemare i bug del logo
.pc = * "Text writer"
.import source "text_writer.asm"
// *SPAZIO* Qua abbiamo ancora $70 bytes

.pc = $3a00  "Elder's functions"
.pseudopc freshcode
{
.fill $40,0						// <-- Mandatory!!
.import source "functions.asm"	// Max size $C0 
// *SPAZIO* Qua abbiamo 34 byte
}

.pc = $3b00 "logo swinger"
.pseudopc freshcode+$100
{
.import source "top_sprite_routine.asm"
.import source "timer.asm"
}
.pc=* "End of code Fresh's code"
