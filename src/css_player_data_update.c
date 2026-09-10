#include "css.h"

#define MENU_MAIN_CSS 2
#define HUD_SIX 8

static const u8 closed_card[] = {0x1A, PKIND_CLOSED, 0, 0, 0, 0xFF, 0, 0, 9, 0, 0x78, 0};

void css_player_data_update() {
    if (css_menu_id != MENU_MAIN_CSS) {
        return;
    }

    match_init_flags &= ~HUD_SIX;

    for (int i = 0; i < 2; ++i) {
        Player * player = &players[4 + i];
        if (triples_converted_output[i].err != 0) {
            memcpy(player, closed_card, sizeof(closed_card));
        } else if (player->slot_type != PKIND_CLOSED) {
            match_init_flags |= HUD_SIX;
        }
    }
}
