// Squeezes the four vanilla doors and spaces them CSS_DOOR_PITCH apart from
// door 0's vanilla position so six fit, moving each door's pieces by joint
// index and transforming its button bounds the same way.  P5/P6's doors and
// every door's name text (css_56_cursor.c) read door 0's result to place
// themselves.

#include "css.h"

#define SQUEEZE 0.66f

// A door's top-level pieces as (door 0 joint, per-door stride) pairs:
// background, emblem, costume, team, name plate and sliders, KO star dots,
// nametag window and its two text anchors, door frame, indicator.
static const u8 pieces[][2] = {
    {0x29, 1}, {0x2E, 1}, {0x33, 1}, {0x38, 1}, {0x3D, 6}, {0x57, 6},
    {0x70, 5}, {0x73, 5}, {0x74, 5}, {0x85, 8}, {0xA5, 2},
};

// Door 0's vanilla HMN and team button bounds relative to its background.
static const f32 bounds[4] = {-5.4f, 1.6f, 3.4f, 9.2f};

void css_rescale_doors() {
    f32 x0 = css_child(css_scene_root, BG_JOINT)->translate[0];
    for (int i = 0; i < 4; ++i) {
        f32 centre = x0 + CSS_DOOR_PITCH * i;
        // t = centre - s * x_i, so x' = s * x + t puts the card at centre.
        f32 t = centre - SQUEEZE * css_child(css_scene_root, BG_JOINT + i)->translate[0];
        for (unsigned p = 0; p < sizeof(pieces) / sizeof(pieces[0]); ++p) {
            HSD_JObj * piece = css_child(css_scene_root, pieces[p][0] + pieces[p][1] * i);
            piece->scale[0] = SQUEEZE;
            piece->translate[0] = piece->translate[0] * SQUEEZE + t;
            HSD_JObjSetMtxDirty(piece);
        }

        // Rescale nametag window to fill the squeezed door.
        HSD_JObj * window = css_child(css_scene_root, NAMETAG_WINDOW_JOINT + 5 * i);
        window->scale[0] = SQUEEZE * NAMETAG_WINDOW_STRETCH;
        window->translate[0] = css_child(css_scene_root, BG_JOINT + i)->translate[0];
        HSD_JObjSetMtxDirty(window);

        // Bounds are rebuilt from the card's centre, not scaled in place: the
        // door array outlives the scene and would drift on every CSS load.
        for (int b = 0; b < 4; ++b) css_doors[i].bounds[b] = bounds[b] * SQUEEZE + centre;
        css_hand_warp_to_spawn(css_hands[i], i);
    }

    // The vanilla name boxes sit at fixed positions, so they cannot follow the
    // doors; css_name_boxes.c replaces them.
    HSD_JObjSetFlagsAll(css_child(css_scene_root, BOX_JOINT), JOBJ_HIDDEN);
}
