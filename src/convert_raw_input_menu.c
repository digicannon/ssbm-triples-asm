#include "melee.h"
#include "triples.h"

#define SCENE_VS 2

#define MINOR_CSS 0
#define MINOR_SSS 1

#define CSS_IN_SUBMENU 5

#define MENU_NAME_ENTRY 0x12

#define DEADZONE 24
static bool is_stick_inactive(s8 x, s8 y) {
    return x >= -DEADZONE && x <= DEADZONE && y >= -DEADZONE && y <= DEADZONE;
}

void convert_raw_input_menu() {
    bool start_only = false;

    if (scene_major > SCENE_VS) return;

    if (scene_major == SCENE_VS) {
        if (scene_minor == MINOR_CSS) {
            if (css_pending_scene_change != CSS_IN_SUBMENU) {
                // This is just to let P5/6 advance from CSS to SSS.
                start_only = true;
            } else if (menu_cur_menu == MENU_NAME_ENTRY) {
                // Name entry for P5/6?
                if (css_name_entry_slot == CSS_NAME_ENTRY_SLOT_56) {
                    // Replace P1 with whoever opened nametag entry.
                    HSD_PadMasterStatus[0] = triples_converted_output[css_name_entry_port - 4];
                    // Disable everyone else since we're in "any input" mode.
                    for (int i = 1; i < 4; ++i) {
                        memset(&HSD_PadMasterStatus[i], 0, offsetof(PadStatus, cross_dir));
                    }
                }

                return;
            }
        }

        // If stage is loading don't copy, or else P5 can make P1 start as Sheik.
        if (scene_minor == MINOR_SSS && sss_stage_picked) return;

        if (scene_minor > MINOR_SSS) return;
    }

    for (int i = 0; i < 2; ++i) {
        const PadStatus * src = &triples_converted_output[i];
        PadStatus * dst = &HSD_PadMasterStatus[i];

        if (src->err != 0) continue;
        dst->err = 0;

        if (start_only) {
            dst->button |= src->button & PAD_BUTTON_START;
            continue;
        }

        dst->button |= src->button;

        // If destination (P1) is inactive, it is replaceable.
        if (is_stick_inactive(dst->stick_x, dst->stick_y)) {
            dst->stick_x = src->stick_x;
            dst->stick_y = src->stick_y;
        }

        if (is_stick_inactive(dst->substick_x, dst->substick_y)) {
            dst->substick_x = src->substick_x;
            dst->substick_y = src->substick_y;
            dst->nml_substick_x = src->nml_substick_x;
            dst->nml_substick_y = src->nml_substick_y;
        }
    }
}
