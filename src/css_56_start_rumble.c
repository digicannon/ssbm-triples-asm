#include "melee.h"

#define RUMBLE_ID_MENU 0
#define RUMBLE_EFFECT_START 0xB
#define RUMBLE_FRAMES_START 0x1E

void css_56_start_rumble() {
    for (int port = 4; port < 6; ++port) {
        if (players[port].slot_type == PKIND_HUMAN && gm_RumbleEnabledForPlayer(port, players[port].nametag)) {
            rumble_start(port, RUMBLE_ID_MENU, RUMBLE_EFFECT_START, RUMBLE_FRAMES_START);
        }
    }
}
