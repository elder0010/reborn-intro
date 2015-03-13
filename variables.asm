.var music = LoadSid("data/Legend_Intro_Remake.sid")

.const PLAY_MUSIC = true

.const border_colour = BLACK

.const top_bg_colour = LIGHT_GRAY
.const bitmap_bg_colour = ORANGE
.const bottom_bg_colour = DARK_GRAY
.const screen_0 = $0400
.const screen_1 = $0800
.const screen_0_d018 = $18 //$1a
.const screen_1_d018 = $28 //$28 //$2a

.const bottom_sprites = $3a00

.const bottom_fake_charset = $2000 //solo 8 bytes per layer di colori sotto le facce

.const plex_ct = $40

.const reset_a = $10
.const reset_x = $11
.const reset_y = $12
.const stabilizer_irq_line = $74
.const counter = $13
.const sprrow = $14

.const page_pt = $15
.const char_pt = $16
.const row_pt = $17
