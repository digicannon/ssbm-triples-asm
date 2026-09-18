#include "css.h"
#include "css_56_cursor.h"

#define TOGGLE_TOP 0.2f
#define TOGGLE_BOTTOM -4.6f
#define TOGGLE_REST -2.2f
#define TEAM_TOP -1.0f
#define TEAM_BOTTOM -5.8f
#define TEAM_REST -3.4f
#define TEAM_COUNT 3

static bool door_busy(int port) {
    const CSSDoor * door = css_port_door(port);
    return door->is_hold_cpu_slider || door->is_hold_handicap_slider ||
           css_port_puck(port)->x5 != 0 || css_port_cursor(port)->state == HAND_HOLDING ||
           css_port_tag(port)->state != 0;
}

static bool in_box(const CSSCursorData * cursor, const f32 * bounds, f32 bottom, f32 top) {
    return cursor->x > bounds[0]
        && cursor->x < bounds[1]
        && cursor->y > bottom
        && cursor->y < top;
}

static void cycle_kind(int port, int door_idx) {
    CSSDoor * door = css_port_door(door_idx);

    // Calculate next kind.
    u8 kind = door->p_kind + 1;
    if (kind == 2) {
        kind = PKIND_CLOSED;
    } else if (kind == 4) {
        if (css_port_pad(door_idx)->err != 0) {
            kind = PKIND_CPU;
        } else {
            kind = PKIND_HUMAN;
        }
    }

    door->p_kind = kind;
    players[door_idx].slot_type = kind;

    bool pick_rand_char = false;
    if (kind == PKIND_CPU) {
        players[door_idx].nametag = NAMETAG_NONE;
        css_port_tag(door_idx)->use_tag = 0;
        if (!door->selected_since_load && port != door_idx) {
            pick_rand_char = true;
        }
    }

    css_port_refresh(door_idx, pick_rand_char);
    menu_sfx(SFX_MOVE);
}

static void cycle_team(int port) {
    CSSDoor * door = css_port_door(port);
    door->team = (door->team + 1) % TEAM_COUNT;
    players[port].team = door->team;
    css_port_refresh(port, false);
    menu_sfx(SFX_MOVE);
}

static void door_buttons_think(HSD_GObj * gobj) {
    for (int port = 0; port < PORT_COUNT; ++port) {
        const PadStatus * pad = css_port_pad(port);
        if (pad->err != 0 || !(pad->trigger & PAD_BUTTON_A)) {
            continue;
        }

        CSSCursorData * cursor = css_port_cursor(port);
        for (int door_idx = 0; door_idx < PORT_COUNT; ++door_idx) {
            if (css_port_sees(port, door_idx)) {
                continue;
            }

            const CSSDoor * door = css_port_door(door_idx);

            bool in_toggle = in_box(cursor, door->bounds, TOGGLE_BOTTOM, TOGGLE_TOP);
            if (!door_busy(door_idx) && in_toggle) {
                cursor->y = TOGGLE_REST;
                cycle_kind(port, door_idx);
                break;
            }

            bool in_team = in_box(cursor, &door->bounds[2], TEAM_BOTTOM, TEAM_TOP);
            if (css_is_teams && door->p_kind != PKIND_CLOSED && in_team) {
                cursor->y = TEAM_REST;
                cycle_team(door_idx);
                break;
            }
        }
    }
}

void css_door_buttons_create() {
    // Priority 4 runs after the cursor procs have moved their hands.
    GObj_AddProc(GObj_Create(4, 5, 0x80), door_buttons_think, 4);
}
