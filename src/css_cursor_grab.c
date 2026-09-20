#include "css.h"
#include "css_56_cursor.h"

#define HELD_BASE 12 // Then kind * PORT_COUNT + door.
#define HOLD_PUCK 0
#define HOLD_CPU 1
#define HOLD_HANDICAP 2
#define SLIDER_REACH 5.0f // Squared.
#define SLIDER_MAX 10.0f
#define HANDICAP_RULE 2
#define JOINT_CPUSLIDER 7
#define JOINT_CPUSLIDER2 8

#define ICON_HELD 0xD // What Melee leaves in sel_icon while a puck is out.
#define REACH 9.0f // Squared.
#define ROW_BOTTOM 0.2f
#define ROW_TOP 22.0f
#define SFX_GRAB 0xB7
#define SFX_DROP 0xB8
#define SFX_DENY 3
#define ANNOUNCE_ID 0x8A

#define HAND_TO_PUCK_DX 2.7f
#define HAND_TO_PUCK_DY -2.0f
#define HAND_TO_KNOB_DX 2.9f
#define HAND_TO_KNOB_DY -1.7f

static u8 css_hands_held; // Bit per port, as of the last frame.

// The puck think has already placed the joint from its own follow of the
// wrong hand this frame, so the joint is moved too.
static void puck_follow(CSSCharModel * puck, const CSSCursorData * hand) {
    puck->x = puck->x10 = hand->x + HAND_TO_PUCK_DX;
    puck->y = puck->x14 = hand->y + HAND_TO_PUCK_DY;
    HSD_JObj * jobj = puck->gobj->hsd_obj;
    jobj->translate[0] = puck->x10;
    jobj->translate[1] = puck->x14;
    HSD_JObjSetMtxDirty(jobj);
}

static bool over_icon(const CSSCharModel * puck, const CSSIcon * icon) {
    return icon->state >= 1
        && puck->x > icon->bound_l && puck->x < icon->bound_r
        && puck->y < icon->bound_u && puck->y > icon->bound_d;
}

static bool over_random_button(const CSSCharModel * puck) {
    return puck->y < 6.0f && puck->y > -1.0f
        && ((puck->x > -30.0f && puck->x < -24.4f) || (puck->x > 24.4f && puck->x < 30.2f));
}

static bool all_icons_shown() {
    for (int i = 0; i < ICON_COUNT; ++i) {
        if (css_icons[i].state < 2) return false;
    }
    return true;
}

static void free_hand(CSSCursorData * hand) {
    hand->state = HAND_FREE;
    hand->x6 = 0;
}

// As Melee's unplug path: a door left without a character rolls one.
static void return_puck(int slot) {
    if (css_return_puck(slot)) css_pick_random_character(slot, 1);
    css_door_refresh(slot);
}

static void grab(int port, int door) {
    CSSCursorData * hand = css_port_cursor(port);
    CSSCharModel * puck = css_port_puck(door);
    // Melee only tests the holder for zero and indexes its hands with it,
    // so any real slot keeps its puck think in bounds.
    puck->x5 = 1;
    hand->state = HAND_HOLDING;
    hand->x6 = HELD_BASE + door;
    css_port_door(door)->sel_icon = ICON_HELD;
    GObj_GXLinkLike(puck->gobj, hand->gobj);
    sfx_play(SFX_GRAB, 0x7F, 0x40);
    hand->x = puck->x - HAND_TO_PUCK_DX;
    hand->y = puck->y - HAND_TO_PUCK_DY;
}

// The CPU level knob moves to the second slider while the handicap rule is
// on; the handicap knob is then on the first.
static HSD_JObj * knob(const CSSDoor * d, int kind) {
    bool second = kind == HOLD_CPU && gmMainLib_GetGameRules()->handicap != 0;
    return css_child(css_scene_root, d->joints[second ? JOINT_CPUSLIDER2 : JOINT_CPUSLIDER]);
}

static u8 * hold_flag(CSSDoor * d, int kind) {
    return kind == HOLD_CPU ? &d->is_hold_cpu_slider : &d->is_hold_handicap_slider;
}

static bool grab_slider(int port, int door, int kind) {
    CSSDoor * d = css_port_door(door);
    if (*hold_flag(d, kind) || d->p_kind != PKIND_CPU) return false;
    if (kind == HOLD_HANDICAP && gmMainLib_GetGameRules()->handicap != HANDICAP_RULE) return false;
    f32 pos[3];
    JObj_WorldPos(knob(d, kind), NULL, pos);
    CSSCursorData * hand = css_port_cursor(port);
    f32 dx = hand->x - (pos[0] - HAND_TO_KNOB_DX);
    f32 dy = hand->y - (pos[1] - HAND_TO_KNOB_DY);
    if (dx * dx + dy * dy >= SLIDER_REACH) return false;
    hand->state = HAND_HOLDING;
    hand->x6 = HELD_BASE + kind * PORT_COUNT + door;
    hand->x = pos[0] - HAND_TO_KNOB_DX;
    hand->y = pos[1] - HAND_TO_KNOB_DY;
    *hold_flag(d, kind) = 1;
    sfx_play(SFX_GRAB, 0x7F, 0x40);
    return true;
}

static void slide(int port, int door, int kind) {
    CSSCursorData * hand = css_port_cursor(port);
    CSSDoor * d = css_port_door(door);
    HSD_JObj * jobj = knob(d, kind);
    f32 pos[3];
    JObj_WorldPos(jobj, NULL, pos);
    f32 base_x = jobj->translate[0] - pos[0];
    f32 x = hand->x + HAND_TO_KNOB_DX + base_x;
    if (x < 0.0f) x = 0.0f;
    if (x > SLIDER_MAX) x = SLIDER_MAX;

    u8 level = (int)(0.8f * x + 0.5f) + 1;
    if (kind == HOLD_CPU) {
        players[door].cpu_level = level;
    } else {
        players[door].handicap = level;
    }
    HSD_ForeachAnim(jobj, HSD_TYPE_JOBJ, TOBJ_MASK, HSD_AObjReqAnim, AOBJ_ARG_AF, (double)level);
    HSD_JObjAnimAll(jobj);
    HSD_ForeachAnim(jobj, HSD_TYPE_JOBJ, TOBJ_MASK, HSD_AObjStopAnim, AOBJ_ARG_AOV, 0, 0);
    jobj->translate[0] = x;
    HSD_JObjSetMtxDirty(jobj);
    // Melee's think has already placed the hand's joint where the stick
    // moved it, so it is put back on the knob too.
    hand->x = x - base_x - HAND_TO_KNOB_DX;
    hand->y = pos[1] - HAND_TO_KNOB_DY;
    HSD_JObj * hand_jobj = hand->gobj->hsd_obj;
    hand_jobj->translate[0] = hand->x;
    hand_jobj->translate[1] = hand->y;
    HSD_JObjSetMtxDirty(hand_jobj);

    if (css_port_pad(port)->trigger & PAD_BUTTON_A) {
        free_hand(hand);
        *hold_flag(d, kind) = 0;
        sfx_play(SFX_GRAB, 0x7F, 0x40);
    }
}

static int icon_under(const CSSCharModel * puck) {
    for (int i = 0; i < ICON_COUNT; ++i) {
        if (over_icon(puck, &css_icons[i])) return i;
    }
    return -1;
}

static void pick(int slot, int icon) {
    players[slot].ckind = css_icons[icon].char_kind;
    HSD_ForeachAnim(css_child(css_scene_root, css_icons[icon].joint_id_vs), HSD_TYPE_JOBJ, TOBJ_MASK,
                    HSD_AObjReqAnim, AOBJ_ARG_AF, 10.0);
    css_icons[icon].anim_timer = 0xC;
    css_pucks[slot]->x5 = 0;
    GObj_GXLinkLike(css_pucks[slot]->gobj, css_hands[3]->gobj);
    css_doors[slot].selected_since_load = 1;
    sfx_play_id(css_icons[icon].sfx, 0x7F, 0x40, icon + ANNOUNCE_ID);
    announce_character(css_icons[icon].char_kind);
}

static void pick_random(int slot) {
    CSSDoor * d = &css_doors[slot];
    css_pick_random_character(slot, 0);
    do {
        d->costume = HSD_Randi(costume_count(css_icons[d->sel_icon].char_kind));
    } while (css_duplicate_costume(slot));
    css_door_refresh(slot);
}

static void hold_puck(int port, int door) {
    CSSCursorData * hand = css_port_cursor(port);
    u32 trigger = css_port_pad(port)->trigger;
    puck_follow(css_port_puck(door), hand);

    // Swapped in, the door's slot indexes every table.
    int slot = css_port_swap_in(door);
    CSSDoor * d = &css_doors[slot];
    const CSSCharModel * puck = css_pucks[slot];
    int icon = icon_under(puck);
    if (icon >= 0) {
        d->sel_icon = icon;
        css_door_refresh(slot);
    } else {
        css_door_portrait(slot, 0, true);
        if (!css_tags[slot].data->use_tag) css_tags[slot].data->text->hidden = 1;
        d->sel_icon_prev = ICON_NONE;
    }

    bool picked = false;
    if (hand->y < ROW_BOTTOM || (trigger & PAD_BUTTON_B)) {
        return_puck(slot);
        free_hand(hand);
        if (hand->y < ROW_BOTTOM) sfx_play(SFX_DROP, 0x7F, 0x40);
    } else if (!(trigger & PAD_BUTTON_A)) {
        css_costume_change(slot, trigger);
    } else if (over_random_button(puck) && all_icons_shown()) {
        pick_random(slot);
        picked = true;
    } else if (icon >= 0) {
        pick(slot, icon);
        picked = true;
    } else {
        menu_sfx(SFX_DENY);
    }
    if (picked) {
        free_hand(hand);
        sfx_play(SFX_DROP, 0x7F, 0x40);
    }
    css_port_swap_out(door);
}

static void grab_think(int port) {
    for (int door = 0; door < PORT_COUNT; ++door) {
        if (css_port_sees(port, door)) continue;
        if (grab_slider(port, door, HOLD_CPU) || grab_slider(port, door, HOLD_HANDICAP)) return;
    }

    CSSCursorData * hand = css_port_cursor(port);
    if (hand->y < ROW_BOTTOM || hand->y > ROW_TOP) return;

    int closest = -1;
    f32 closest_dist = REACH;
    for (int door = 0; door < PORT_COUNT; ++door) {
        if (css_port_sees(port, door)) continue;
        const CSSDoor * d = css_port_door(door);
        const CSSCharModel * puck = css_port_puck(door);
        if (d->p_kind != PKIND_CPU || d->sel_icon >= ICON_NONE || puck->x5 != 0) continue;
        // Melee's reach test, offset to the puck's grip.
        f32 dx = 3.8f + (hand->x - puck->x);
        f32 dy = -2.6f + (hand->y - puck->y);
        f32 dist = dx * dx + dy * dy;
        if (dist < closest_dist) {
            closest_dist = dist;
            closest = door;
        }
    }
    if (closest >= 0) grab(port, closest);
}

static void cursor_grab_think(HSD_GObj * gobj) {
    // Melee's hand think has already run, so a hand that dropped on this
    // A press looks free; it was holding last frame.
    u8 was_held = css_hands_held;
    css_hands_held = 0;
    for (int port = 0; port < PORT_COUNT; ++port) {
        CSSCursorData * hand = css_port_cursor(port);
        if (hand->state == HAND_HOLDING) css_hands_held |= 1 << port;
        if (hand->x6 >= HELD_BASE) {
            int kind = (hand->x6 - HELD_BASE) / PORT_COUNT;
            int door = (hand->x6 - HELD_BASE) % PORT_COUNT;
            if (hand->state != HAND_HOLDING) {
                // The holder unplugged or closed; Melee did not know it held.
                if (kind == HOLD_PUCK) {
                    return_puck(css_port_swap_in(door));
                    css_port_swap_out(door);
                } else {
                    *hold_flag(css_port_door(door), kind) = 0;
                }
                hand->x6 = 0;
            } else if (kind == HOLD_PUCK) {
                hold_puck(port, door);
            } else {
                slide(port, door, kind);
            }
            continue;
        }

        const PadStatus * pad = css_port_pad(port);
        if (pad->err != 0 || !(pad->trigger & PAD_BUTTON_A)) continue;
        if (hand->state == HAND_HOLDING || (was_held & (1 << port)) || css_port_tag(port)->state != 0) continue;
        grab_think(port);
    }
}

void css_cursor_grab_create() {
    css_hands_held = 0;
    // Priority 4 runs after the hand and puck procs.
    GObj_AddProc(GObj_Create(4, 5, 0x80), cursor_grab_think, 4);
}
