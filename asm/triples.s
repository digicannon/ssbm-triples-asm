.ifndef TRIPLES_S
.set TRIPLES_S, 1

.set DEBUG, 0

.set BTN_MASK_START, 0b00010000 << 8
.set BTN_MASK_L, 0b01000000
.set BTN_MASK_R, 0b00100000
.set BTN_MASK_Z, 0b00010000

.set triples_nintendont_data,  0x803FC500 # Reserved size 0x100, more than required.
.set triples_converted_output, 0x803FC600 # Size 0x88.

.set begin_triples_globals, 0x803FC700
.set widescreen_enabled, begin_triples_globals # Nintendont depends on this being at this address.
.set match_player_count, widescreen_enabled + 4
.set match_frames_since_indicator_switch, match_player_count + 4
.set pause_56_images, match_frames_since_indicator_switch + 4 # Heap block, per match.
.set css_56_blocks, pause_56_images + 4 # P5 and P6's CSS blocks, per CSS load.

.endif
