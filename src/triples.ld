/* Nintendont's HID data in Wii memory. */
hid_status = 0x93003440;
hid_ctrl = 0x93005000;
hid_report = 0x930050F0;
hid_motor_56 = 0x93003028; /* Rumble mask for the adapter, bit per port.  Nintendont depends on this address. */

adapter_pads_data = 0x803FC500; /* Reserved size 0x100, more than required. */
triples_converted_output = 0x803FC600; /* Size 0x88. */
rumble_data = 0x803FC6B0; /* Six HSD_RumbleData, 0x48. */

widescreen_enabled = 0x803FC700; /* Nintendont depends on this address. */
