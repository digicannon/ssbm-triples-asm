#include "css.h"
#include "css_56_cursor.h"

static void show_box(HSD_JObj * root, int box, int slot) {
    HSD_JObj * joint = css_child(root, BOX_JOINT_BASE + box);
    bool show = (css_doors[slot].p_kind == PKIND_CLOSED) || (css_tags[slot].data->state != 0);
    if (show) {
        HSD_JObjSetFlagsAll(joint, JOBJ_HIDDEN);
    } else {
        HSD_JObjClearFlagsAll(joint, JOBJ_HIDDEN);
    }
}

void css_56_scene_anim(HSD_JObj * root) {
    int port = css_56_swapped_port();

    if (port < 0) {
        // No swap, vanilla path.

        for (int i = 0; i < 4; ++i) {
            show_box(root, i, i);
        }

        // This should only be called once per frame,
        // we're taking advantage of this "no swap" path
        // only happening once to do so.
        HSD_JObjAnimAll(root);
    } else {
        show_box(root, port, 0);
    }
}

HOOK(0x8025FA9C, "bl css_56_scene_anim");
