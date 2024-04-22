.set DEBUG, 1

.set BTN_MASK_START, 0b00010000 << 8
.set BTN_MASK_L, 0b01000000
.set BTN_MASK_R, 0b00100000
.set BTN_MASK_Z, 0b00010000

.set CSS_PuckObjPointers, 0x804A0BD0

# ================
# Triples globals.
# ================

# Free memory exists from debug strings from 0x803FA3E8 to 0x803FC2EC.

.set triples_puck_datas,   0x803FA3E8
.set triples_puck_data_p5, 0x803FA3E8
.set triples_puck_data_p6, 0x803FA3EC
