#include "mex.h"

#include "triples.h"

CSSIcon * css_icon_table() {
    if (mex_is_loaded()) {
        return (CSSIcon *)(mex_css_data + MEX_CSS_ICONS);
    } else {
        return css_icons;
    }
}

int css_icon_count() {
    if (mex_is_loaded()) {
        return mex_css_icon_count;
    } else {
        return ICON_COUNT;
    }
}

HSD_JObj * css_icon_joint(int icon) {
    HSD_JObj * out = NULL;
    if (mex_is_loaded() && mex_select_chr) {
        JObj_GetChild(mex_icon_root, &out, icon + 1, -1);
    } else {
        JObj_GetChild(css_scene_root, &out, css_icons[icon].joint_id_vs, -1);
    }
    return out;
}

bool css_miss_picks_random() {
    return mex_is_loaded();
}

void mex_add_door_anims(HSD_JObj * costume, HSD_JObj * emblem) {
    if (!mex_is_loaded()) {
        return;
    }

    if (mex_select_chr) {
        HSD_DObjAddAnimAll(costume->dobj, mex_select_chr->csp_matanim, NULL);
    }

    HSD_MatAnimJoint * emblems = HSD_ArchiveGetPublicAddress(lbDvd_GetArchiveByName("IfAll"), "Eblm_matanim_joint");
    if (emblems) {
        HSD_DObjAddAnimAll(emblem->dobj->next, emblems->matanim, NULL);
    }
}

/** lbHeap_80015F3C, copying a heap descriptor's size.  m-ex supplies its own
    descriptors, so AllA always takes its size from the vanilla table,
    which Triples sets. */
HOOK(0x80016054,
    "lwz r4, 0(r3)\n"
    "cmpwi r4, 5\n" // AllA.
    "bne mex_alla_size_done\n"
    "loadwz r4, 0x803BA3BC\n" // AllA's size in lbHeap_803BA380.
    "stw r4, 0xC(r3)\n"
    "mex_alla_size_done:\n"
    "lwz r0, 0xC(r3)"); // Original code.
