#include "melee.h"
#include "triples.h"

#define EXISTING_ENTRIES 5
#define ENTRY_SIZE 4

#define SHIELD_TINT 35
#define BLASTZONE_TINT 80

// Every row is a fully saturated hue washed toward white.  P5/P6's colors are
// not fully saturated, so stretch each to its hue first or the row comes out
// pale.
static void fill(u8 table[][ENTRY_SIZE], const u8 * original, int tint) {
    static const GXColor colors[2] = {P5_COLOR, P6_COLOR};
    memcpy(table, original, EXISTING_ENTRIES * ENTRY_SIZE);
    for (int i = 0; i < 2; ++i) {
        const u8 * rgb = &colors[i].r;
        int low = rgb[0], high = rgb[0];
        for (int c = 1; c < 3; ++c) {
            if (rgb[c] < low) low = rgb[c];
            if (rgb[c] > high) high = rgb[c];
        }
        u8 * entry = table[EXISTING_ENTRIES + i];
        // Washing toward the color's own ceiling rather than white keeps a
        // darker color dark.
        for (int c = 0; c < 3; ++c) {
            int hue = (rgb[c] - low) * high / (high - low);
            entry[c] = hue + (high - hue) * tint / 100;
        }
        entry[3] = 0;
    }
}

int shield_and_blastzone_colors_56_index(int slot, int index) {
    if (ft_shield_colors != shield_colors_56[0]) {
        fill(shield_colors_56, ft_shield_colors, SHIELD_TINT);
        fill(blastzone_colors_56, ft_blastzone_colors, BLASTZONE_TINT);
        ft_shield_colors = shield_colors_56[0];
        ft_blastzone_colors = blastzone_colors_56[0];
    }

    if (slot < 4 || css_is_teams || Player_GetPlayerSlotType(slot) != PKIND_HUMAN) {
        return index;
    } else {
        return EXISTING_ENTRIES + slot - 4;
    }
}
