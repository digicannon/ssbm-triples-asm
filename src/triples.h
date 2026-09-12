#ifndef TRIPLES_H
#define TRIPLES_H

#include "melee.h"

/// css_name_entry_slot value while P5/P6 has the keyboard.
#define CSS_NAME_ENTRY_SLOT_56 4

#define P5_COLOR {0xCC, 0x7A, 0x1E, 0xFF}
#define P6_COLOR {0x98, 0x4C, 0xE5, 0xFF}

int color_brightness(GXColor color, int * darkness_out);
GXColor color_hue(GXColor color);
GXColor color_retint(GXColor hue, GXColor sat_bright_source);

#endif
