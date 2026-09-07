// The tail of the scene proc, where it animates the whole scene tree.  Two
// things ride on it:
//
// The name boxes (css_name_boxes.c) sit at the end of the tree and would
// draw over a closed door, so each is shown only while its door is open.  In
// the real call doors 0-3 are the stock doors; in a P5/P6 card proc call
// (slot 0 swapped for the port) door 0 is that port's.
//
// P5/P6's card procs run this proc too for their door timers; only the real
// call may animate the scene.

#include "css.h"
#include "css_56_cursor.h"

// Box follows the door in that slot.
static void show_box(HSD_JObj * root, int box, int slot) {
    HSD_JObj * joint = css_child(root, BOX_JOINT_BASE + box);
    if (css_doors[slot].p_kind == PKIND_CLOSED) HSD_JObjSetFlagsAll(joint, JOBJ_HIDDEN);
    else HSD_JObjClearFlagsAll(joint, JOBJ_HIDDEN);
}

void css_56_scene_anim(HSD_JObj * root) {
    int port = css_56_swapped_port();
    if (port >= 0) {
        show_box(root, port, 0);
        return;
    }

    for (int i = 0; i < 4; ++i) show_box(root, i, i);
    HSD_JObjAnimAll(root);
}
