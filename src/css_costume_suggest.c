#include "css_56_cursor.h"

#define MAX_UNIQUE_COSTUMES 6

void css_costume_suggest(int slot) {
    CSSDoor * door = &css_doors[slot];

    if (css_door_count != 4 || door->sel_icon >= ICON_NONE) {
        return;
    }

    int swapped = css_56_swapped_port();
    int self = (swapped >= 0) ? swapped : slot;

    u8 taken[MAX_UNIQUE_COSTUMES] = {0};
    for (int port = 0; port < PORT_COUNT; ++port) {
        const CSSDoor * other = css_get_door_for_port_swap_aware(port);

        if (port == self || other->p_kind == PKIND_CLOSED || other->sel_icon != door->sel_icon) {
            continue;
        }

        if (other->costume < MAX_UNIQUE_COSTUMES) {
            ++taken[other->costume];
        }
    }

    int count = costume_count(css_icons[door->sel_icon].char_kind);
    door->costume = 0;
    for (int i = 1; i < count; ++i) {
        if (taken[i] < taken[door->costume]) {
            door->costume = i;
        }
    }
}

HOOK(0x8025DCD4,
    "mr r3, r31\n"
    "bl css_costume_suggest\n"
    "lbz r0, -0x49AA(r13)"); // Original code.
