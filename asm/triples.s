.ifndef TRIPLES_S

.set DEBUG, 1

.set BTN_MASK_START, 0b00010000 << 8
.set BTN_MASK_L, 0b01000000
.set BTN_MASK_R, 0b00100000
.set BTN_MASK_Z, 0b00010000

.set triples_nintendont_data,  0x803FC500 # Reserved size 0x100, more than required.
.set triples_converted_output, 0x803FC600 # Size 0x88.

.set begin_triples_globals, 0x803fa3e8
.set dbg_text_gobj, begin_triples_globals + 16
.set dbg_subtext_str, dbg_text_gobj + 4
.set css_run_once, dbg_subtext_str + 4
.set css_p5_border_jobj, css_run_once + 4
.set css_backup_space, css_p5_border_jobj + 4
.set css_backup_dbg, css_backup_space + 4 #803fa40c
.set css_end_backup_space, css_run_once + 64
.set css_manually_animate, css_end_backup_space + 4
.set css_open_doors, css_manually_animate + 4
.set css_p5_portrait, css_open_doors + 4
.set css_p5_door_jobj, css_p5_portrait + 4
.set css_p5_text_gobj, css_p5_door_jobj + 4
.set css_p5_text_subtext, css_p5_text_gobj + 4
.set css_p1_door, css_p5_text_subtext + 4

.set p2_char_select, 0x803F0E2C # 2 bytes off from the sheet, but i watched it happen

.set TRIPLES_S, 1
.endif
