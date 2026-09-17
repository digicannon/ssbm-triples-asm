#include "css.h"

#define MENU_MAIN_CSS 2
#define HUD_SIX 8

void css_player_data_update() {
    if (css_menu_id != MENU_MAIN_CSS) {
        return;
    }

    match_init_flags &= ~HUD_SIX;
    for (int i = 4; i < 6; ++i) {
        if (players[i].slot_type != PKIND_CLOSED) match_init_flags |= HUD_SIX;
    }
}
