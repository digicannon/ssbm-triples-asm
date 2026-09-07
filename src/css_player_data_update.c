// Per frame on the CSS: P5/P6's player table entries follow P1/P2's, except
// for the fields the CSS keeps current for them itself, and the HUD grows to
// six slots while either door is open.

#include "css.h"

enum {
    MENU_MAIN_CSS = 2,
    HUD_SIX = 8,
    // Character, HMN/CPU, stocks, costume; slot, x5, spawn dir, sub colour;
    // handicap, team, nametag.
    CARD_BYTES = 12,
};

// A closed door: no character, nametag 0x78 (none), handicap 9.
static const u8 closed_card[CARD_BYTES] = {0x1A, PKIND_CLOSED, 0, 0, 0, 0xFF, 0, 0, 9, 0, 0x78, 0};

void css_player_data_update() {
    if (css_menu_id != MENU_MAIN_CSS) return;
    match_init_flags &= ~HUD_SIX;

    for (int i = 0; i < 2; ++i) {
        Player * player = &players[4 + i];
        if (triples_converted_output[i].err != 0) {
            memcpy(player, closed_card, CARD_BYTES);
            continue;
        }

        Player kept = *player;
        memcpy(player, &players[i], CARD_BYTES);
        player->ckind = kept.ckind;
        player->slot_type = kept.slot_type;
        player->color = kept.color;
        player->handicap = kept.handicap;
        player->team = kept.team;
        if (player->slot_type != PKIND_CLOSED) match_init_flags |= HUD_SIX;
    }
}
