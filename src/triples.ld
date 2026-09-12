/* Nintendont's HID data in Wii memory. */
hid_status = 0x93003440;
hid_ctrl = 0x93005000;
hid_report = 0x930050F0;

adapter_pads_data = 0x803FC500; /* Reserved size 0x100, more than required. */
triples_converted_output = 0x803FC600; /* Size 0x88. */

begin_triples_globals = 0x803FC700;
widescreen_enabled = begin_triples_globals; /* Nintendont depends on this address. */
match_player_count = widescreen_enabled + 4;
match_frames_since_indicator_switch = match_player_count + 4;
pause_56_images = match_frames_since_indicator_switch + 4; /* Heap block, per match. */
css_56_blocks = pause_56_images + 4; /* P5 and P6's CSS blocks, per CSS load. */
css_name_entry_port = css_56_blocks + 8; /* Which of P5/P6 asked for name entry. */
shield_colors_56 = css_name_entry_port + 4; /* 7 RGBx entries. */
blastzone_colors_56 = shield_colors_56 + 28;
