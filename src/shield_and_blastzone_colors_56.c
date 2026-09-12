#include "melee.h"
#include "triples.h"

#define EXISTING_ENTRIES 5
#define ENTRY_SIZE 4

static void fill(u8 table[][ENTRY_SIZE], const u8 * original) {
    static const GXColor colors[2] = {P5_COLOR, P6_COLOR};

    memcpy(table, original, EXISTING_ENTRIES * ENTRY_SIZE);
    GXColor p1 = {table[0][0], table[0][1], table[0][2], 0};

    for (int i = 0; i < 2; ++i) {
        GXColor row = color_retint(color_hue(colors[i]), p1);
        int brightness = color_brightness(colors[i], NULL);

        u8 * entry = table[EXISTING_ENTRIES + i];
        for (int c = 0; c < 3; ++c) {
            entry[c] = (&row.r)[c] * brightness / 0xFF;
        }
        entry[3] = 0;
    }
}

int shield_and_blastzone_colors_56_index(int slot, int index) {
    if (ft_shield_colors != shield_colors_56[0]) {
        fill(shield_colors_56, ft_shield_colors);
        fill(blastzone_colors_56, ft_blastzone_colors);
        ft_shield_colors = shield_colors_56[0];
        ft_blastzone_colors = blastzone_colors_56[0];
    }

    if (slot < 4 || css_is_teams || Player_GetPlayerSlotType(slot) != PKIND_HUMAN) {
        return index;
    } else {
        return EXISTING_ENTRIES + slot - 4;
    }
}
