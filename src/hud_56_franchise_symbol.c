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
