#ifndef CSS_DOOR_TEXT_H
#define CSS_DOOR_TEXT_H

#include "melee.h"

// A door's name text as the vanilla makes it.
void css_door_text_create(HSD_JObj * anchor, CSSTagData * tag, const Player * player);

// A door's tag list as the vanilla makes it, on the list joint.
void css_door_list_create(HSD_JObj * window, HSD_JObj * anchor, CSSTagData * tag);
void css_door_list_place(HSD_JObj * window, HSD_JObj * anchor, Text * list);

// Remakes P1-P4's texts, which the vanilla laid out before css_rescale_doors.
void css_door_texts_remake();

#endif
