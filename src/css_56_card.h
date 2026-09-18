#ifndef CSS_56_CARD_H
#define CSS_56_CARD_H

#include "melee.h"

// Loads, animates and grafts the card, and makes the tag's texts on it.
HSD_JObj * css_56_card_create(int port, CSSTagData * tag);

// Door 0's and tag 0's joint ids moved onto the port's card.
void css_56_card_set_joint_ids(int port, CSSDoor * door, CSSTag * tag);

// Tints the card background.
void css_56_card_set_color(HSD_JObj * card, GXColor color);

#endif
