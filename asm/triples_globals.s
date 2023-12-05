.ifndef HEADER_GLOBALS

TRIPLES_GLOBALS_TABLE:
.set begin_triples_globals, 0x803fa3e8
.set dbg_text_gobj, begin_triples_globals + 16
.set dbg_subtext_str, dbg_text_gobj + 4
.set css_run_once, dbg_subtext_str + 4
.set css_p5_border_jobj, css_run_once + 4
.set css_backup_space, css_p5_border_jobj + 4
.set css_end_backup_space, css_run_once + 64
.set css_manually_animate, css_end_backup_space + 4
.set css_p5_portrait, css_manually_animate + 4

.set p2_char_select, 0x803F0E2C # 2 bytes off from the sheet, but i watched it happen

.endif
.set HEADER_GLOBALS, 1
