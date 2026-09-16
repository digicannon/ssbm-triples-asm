#include "melee.h"
#include "triples.h"

#define ANY_PORT 4

#define SCENE_VS 2
#define MINOR_CSS 0
#define CSS_IN_SUBMENU 5
#define MENU_NAME_ENTRY 0x12

// Sets `to` in each word holding any of `from`.
static void map_any(ControllerMapEntry * e, u64 from, u64 to) {
    if (e->button & from) e->button |= to;
    if (e->repeat & from) e->repeat |= to;
    if (e->trigger & from) e->trigger |= to;
    if (e->release & from) e->release |= to;
}

// Sets `to` where all of `from` are held.
static void map_all(ControllerMapEntry * e, u64 from, u64 to) {
    if ((e->button & from) == from) {
        e->button |= to;
        if (e->trigger & from) e->trigger |= to;
        if (e->release & from) e->release |= to;
    }
    if ((e->repeat & from) == from) e->repeat |= to;
}

static void repeat(ControllerMapEntry * e) {
    const ControllerMap * m = &controller_map;

    if (e->trigger || e->release) {
        e->repeat2 = e->trigger;
        e->repeat_timer = m->delay;
        e->held = 0;
        return;
    }

    if (e->held < m->fastest_after) {
        ++e->held;
    }

    if (e->repeat_timer) {
        --e->repeat_timer;
        e->repeat2 = 0;
        return;
    }

    e->repeat2 = e->button;
    e->repeat_timer = e->held >= m->fastest_after ? m->fastest_interval
                    : e->held >= m->fast_after ? m->fast_interval
                    : m->interval;
}

static void merge(ControllerMapEntry * any, const ControllerMapEntry * e) {
    any->button |= e->button;
    any->trigger |= e->trigger;
    any->repeat |= e->repeat;
    any->release |= e->release;
    any->repeat2 |= e->repeat2;
}

static bool in_name_entry_for_56() {
    return scene_major == SCENE_VS && scene_minor == MINOR_CSS
        && css_pending_scene_change == CSS_IN_SUBMENU
        && menu_cur_menu == MENU_NAME_ENTRY
        && css_name_entry_slot == CSS_NAME_ENTRY_SLOT_56;
}

void menu_inputs_56() {
    for (int i = 0; i < 2; ++i) {
        ControllerMapEntry * e = &menu_inputs_56_ports[i];
        const PadStatus * pad = &triples_converted_output[i];
        e->button = pad->button;
        e->trigger = pad->trigger;
        e->repeat = pad->repeat;
        e->release = pad->release;
        map_any(e, PAD_BUTTON_A | PAD_BUTTON_START, PAD_CONFIRM);
        map_any(e, PAD_BUTTON_B, PAD_CANCEL);
        map_all(e, PAD_TRIGGER_L | PAD_TRIGGER_R | PAD_BUTTON_START, PAD_LR_START);
        map_all(e, PAD_TRIGGER_L | PAD_TRIGGER_R | PAD_BUTTON_A | PAD_BUTTON_START, PAD_LRA_START);
        map_any(e, PAD_BUTTON_UP | PAD_STICK_UP, PAD_ANY_UP);
        map_any(e, PAD_BUTTON_DOWN | PAD_STICK_DOWN, PAD_ANY_DOWN);
        map_any(e, PAD_BUTTON_LEFT | PAD_STICK_LEFT, PAD_ANY_LEFT);
        map_any(e, PAD_BUTTON_RIGHT | PAD_STICK_RIGHT, PAD_ANY_RIGHT);
        repeat(e);
    }

    ControllerMapEntry * any = &controller_map.ports[ANY_PORT];
    if (in_name_entry_for_56()) {
        // We set the keyboard to "any mode", so write 5/6 to that.
        memset(any, 0, offsetof(ControllerMapEntry, repeat_timer));
        merge(any, &menu_inputs_56_ports[css_name_entry_port - 4]);
        return;
    }

    for (int i = 0; i < 2; ++i) {
        merge(any, &menu_inputs_56_ports[i]);
    }
}
