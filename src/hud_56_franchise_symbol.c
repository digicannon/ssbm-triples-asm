#include "melee.h"
#include "triples.h"

void hud_56_franchise_symbol_color(HSD_MObj * mobj, int slot) {
    if (slot < 4 || css_is_teams || Player_GetPlayerSlotType(slot) != PKIND_HUMAN) {
        return;
    }

    static const GXColor colors[2] = {P5_COLOR, P6_COLOR};
    mobj->mat->diffuse.r = colors[slot - 4].r;
    mobj->mat->diffuse.g = colors[slot - 4].g;
    mobj->mat->diffuse.b = colors[slot - 4].b;
}

HOOK(0x802F64F0,
    "mr r3, r4\n" // The symbol's MObj.
    "mr r4, r31\n" // The player slot.
    "bl hud_56_franchise_symbol_color\n"
    "lwz r3, 4(r29)"); // Original code.
