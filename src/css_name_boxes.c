// The stock name boxes are four meshes in one joint at fixed positions,
// which css_rescale_doors.c hides.  Each of the six doors gets its own copy
// of that joint showing one box, placed like the door's pieces:
// x' = s * x + x0 + CSS_DOOR_PITCH * i - s * x_i, where x_i is the stock
// background x of the door whose box it is (door 0's for P5/P6).  Grafted
// after P5/P6's subtrees, so the boxes are joints BOX_JOINT_BASE + i;
// css_56_scene_anim.c shows each only while its door is open.

#include "css.h"

void css_name_boxes() {
    int index = BOX_JOINT;
    HSD_JObjDesc * box_desc = css_find_node(css_anim_table[ANIM_SCENE].desc[KIND_JOINT], KIND_JOINT, &index);
    index = BOX_JOINT;
    void * box_matanim = css_find_node(css_anim_table[ANIM_SCENE].desc[KIND_MATANIM], KIND_MATANIM, &index);

    const HSD_JObj * bg0 = css_child(css_scene_root, BG_JOINT);
    f32 squeeze = bg0->scale[0];
    f32 x0 = bg0->translate[0];

    for (int i = 0; i < 6; ++i) {
        int door = i < 4 ? i : 0;
        // Stock x of the door whose box this is.
        index = BG_JOINT + door;
        const HSD_JObjDesc * bg = css_find_node(css_anim_table[ANIM_SCENE].desc[KIND_JOINT], KIND_JOINT, &index);
        HSD_JObj * box = HSD_JObjLoadJoint(box_desc);
        HSD_JObjAddAnimAll(box, NULL, box_matanim, NULL);
        HSD_JObjReqAnimAll(box, 0.0f);
        HSD_JObjAnimAll(box);

        // Show only this door's box.
        int mesh = 0;
        for (HSD_DObj * dobj = box->dobj; dobj; dobj = dobj->next, ++mesh) {
            if (mesh != door) dobj->pobj->display_count = 0;
        }

        // Hidden until the scene proc shows it for an open door.
        HSD_JObjSetFlagsAll(box, JOBJ_HIDDEN);
        box->scale[0] = squeeze;
        box->translate[0] = x0 + CSS_DOOR_PITCH * i - squeeze * bg->position[0];
        box->translate[1] = 0.0f;
        HSD_JObjSetMtxDirty(box);
        HSD_JObjAddChild(css_scene_root, box);
    }
}
