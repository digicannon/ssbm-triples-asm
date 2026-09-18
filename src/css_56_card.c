#include "css_56_card.h"

#include "css.h"
#include "css_door_text.h"

#define PLATE_JOINT 0x3D // Door 0's name plate: skinned, six joints.
#define PLATE_JOINTS 6
#define SCENE_JOINTS 0xAD // Joints in the VS scene; grafts index from here.
#define GRAFT_JOINTS 31 // Root plus door 0's pieces.

// Joint indices of door 0's pieces in a card, in door_pieces order.
#define CARD_BG 1
#define CARD_EMBLEM 2
#define CARD_COSTUME 3
#define CARD_TEAM 4
#define CARD_PLATE 5 // Six joints.
#define CARD_CPUSLIDER2 8
#define CARD_CPUSLIDER 9
#define CARD_DOTS 11
#define CARD_NAMETAG_WINDOW 17
#define CARD_LIST 20
#define CARD_NAME 21
#define CARD_DOOR 22
#define CARD_INDICATOR 30

// Door 0's top-level joints in the VS scene with their group parents:
// background, emblem, costume, team, name plate and sliders, KO star dots,
// nametag window and its two text anchors, door frame, indicator.
static const u8 door_pieces[][2] = {
    {0x29, 0x28}, {0x2E, 0x2D}, {0x33, 0x32}, {0x38, 0x37}, {0x3D, 0x3C},
    {0x57, 0x56}, {0x70, 0x6F}, {0x73, 0x6F}, {0x74, 0x6F}, {0x85, 0x84},
    {0xA5, 0xA4},
};

// CSSDoor joints, then CSSTag joints, in the graft.
static const u8 door_graft_ids[9] = {CARD_EMBLEM, CARD_COSTUME, CARD_TEAM, CARD_DOOR, CARD_BG, CARD_INDICATOR, 5, CARD_CPUSLIDER, CARD_CPUSLIDER2};
static const u8 tag_graft_ids[5] = {CARD_NAMETAG_WINDOW, CARD_LIST, CARD_NAME, 19, 18};

static void * copy_chain(const void * node, int kind);

// A copy of the node, without its siblings.
static void * copy_node(const void * node, int kind, bool with_children) {
    if (!node) return NULL;
    void * copy = HSD_MemAlloc(css_node_kinds[kind].size);
    memcpy(copy, node, css_node_kinds[kind].size);
    NEXT(copy, kind) = NULL;
    CHILD(copy, kind) = with_children ? copy_chain(CHILD(node, kind), kind) : NULL;
    return copy;
}

static void * copy_chain(const void * node, int kind) {
    if (!node) return NULL;
    void * copy = copy_node(node, kind, true);
    NEXT(copy, kind) = copy_chain(NEXT(node, kind), kind);
    return copy;
}

static void free_tree(void * node, int kind) {
    if (!node) return;
    free_tree(CHILD(node, kind), kind);
    free_tree(NEXT(node, kind), kind);
    HSD_Free(node);
}

// A copy of the scene's root of that kind whose only children are door 0's
// pieces, in door_pieces order.  Only needed while loading; free_tree after.
static void * build_tree(int kind) {
    void * scene = css_anim_table[ANIM_SCENE].desc[kind];
    void * root = copy_node(scene, kind, false);
    void * prev = NULL;
    for (unsigned i = 0; i < sizeof(door_pieces) / sizeof(door_pieces[0]); ++i) {
        int index = door_pieces[i][0];
        void * copy = copy_node(css_find_node(scene, kind, &index), kind, true);
        if (kind == KIND_JOINT) {
            // Joints lose their group parent, so its translation moves into
            // the copy (the groups have no scale or rotation).
            index = door_pieces[i][1];
            HSD_JObjDesc * group = css_find_node(scene, kind, &index);
            HSD_JObjDesc * joint = copy;
            for (int axis = 0; axis < 3; ++axis) joint->position[axis] += group->position[axis];
        }
        if (prev) NEXT(prev, kind) = copy;
        else CHILD(root, kind) = copy;
        prev = copy;
    }
    return root;
}

// Maps the plate's six original descs to that tree's plate joints.
static void bind_plate(HSD_JObj * tree, int plate) {
    for (int i = 0; i < PLATE_JOINTS; ++i) {
        int index = PLATE_JOINT + i;
        void * desc = css_find_node(css_anim_table[ANIM_SCENE].desc[KIND_JOINT], KIND_JOINT, &index);
        HSD_IDInsertToTable(NULL, desc, css_child(tree, plate + i));
    }
}

HSD_JObj * css_56_card_create(int port, CSSTagData * tag) {
    void * joint_tree = build_tree(KIND_JOINT);
    void * anim_tree = build_tree(KIND_ANIM);
    void * matanim_tree = build_tree(KIND_MATANIM);

    HSD_JObj * card = HSD_JObjLoadJoint(joint_tree);
    // The plate is skinned to joints found by desc through the ID table,
    // which still names the real door 0's.  Point those descs at the copy,
    // resolve again, and point them back.
    bind_plate(card, CARD_PLATE);
    HSD_JObjResolveRefsAll(card, joint_tree);
    bind_plate(css_scene_root, PLATE_JOINT);
    HSD_JObjAddAnimAll(card, anim_tree, matanim_tree, NULL);
    HSD_JObjReqAnimAll(card, 0.0f);
    HSD_JObjAnimAll(card);
    HSD_ForeachAnim(card, HSD_TYPE_JOBJ, ALL_TYPE_MASK, HSD_AObjStopAnim, HSD_TYPE_JOBJ, 0, 0);
    free_tree(joint_tree, KIND_JOINT);
    free_tree(anim_tree, KIND_ANIM);
    free_tree(matanim_tree, KIND_MATANIM);

    // Squeezed like the vanilla doors and placed CSS_DOOR_PITCH * port
    // right of where door 0 ended up.
    const HSD_JObj * bg0 = css_child(css_scene_root, BG_JOINT);
    f32 squeeze = bg0->scale[0];
    card->scale[0] = squeeze;
    card->translate[0] = bg0->translate[0] - css_child(card, CARD_BG)->translate[0] * squeeze + CSS_DOOR_PITCH * port;
    HSD_JObjSetMtxDirty(card);
    HSD_JObj * window = css_child(card, CARD_NAMETAG_WINDOW);
    window->scale[0] = NAMETAG_WINDOW_STRETCH;
    window->translate[0] = css_child(card, CARD_BG)->translate[0];
    HSD_JObjSetMtxDirty(window);

    // Triples shows no KO stars.
    HSD_JObjSetFlagsAll(css_child(card, CARD_DOTS), JOBJ_HIDDEN);
    HSD_JObjAddChild(css_scene_root, card);

    const Player * player = &players[port];
    css_door_text_create(css_child(card, CARD_NAME), tag, player);
    css_door_list_create(css_child(card, CARD_NAMETAG_WINDOW), css_child(card, CARD_LIST), tag);

    // CPU level knob at the saved level, as the vanilla leaves its doors.
    // With handicap on the level moves to cpuslider2 and css_door_refresh
    // places the handicap knob.
    HSD_JObj * knob = css_child(card, gmMainLib_GetGameRules()->handicap ? CARD_CPUSLIDER2 : CARD_CPUSLIDER);
    knob->translate[0] = (player->cpu_level - 1) * 1.25f;
    HSD_JObjSetMtxDirty(knob);
    return card;
}

void css_56_card_set_joint_ids(int port, CSSDoor * door, CSSTag * tag) {
    int graft = SCENE_JOINTS + GRAFT_JOINTS * (port - 4);
    for (int i = 0; i < 9; ++i) door->joints[i] = door_graft_ids[i] + graft;
    for (int i = 0; i < 5; ++i) tag->joints[i] = tag_graft_ids[i] + graft;
}

void css_56_card_set_color(HSD_JObj * card, GXColor color) {
    static const GXColor inner_line = {0x2C, 0x2C, 0x2C, 0xFF};
    HSD_TObjTev * tev = css_child(card, CARD_BG)->dobj->mobj->tobj->tev;
    tev->konst.r = color.r;
    tev->konst.g = color.g;
    tev->konst.b = color.b;
    tev->tev0.r = inner_line.r;
    tev->tev0.g = inner_line.g;
    tev->tev0.b = inner_line.b;
}
