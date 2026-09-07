// Shared by the CSS sources; src/css.c is linked before them.

#ifndef CSS_H
#define CSS_H

#include "melee.h"

enum {
    ANIM_HAND = 1,
    ANIM_PUCK = 2,
    ANIM_SCENE = 3,
    BG_JOINT = 0x29, // A door's background, door 0's here.
    BOX_JOINT = 0x55, // The four stock name boxes, one mesh each.
    BOX_JOINT_BASE = 0xEB, // Our name boxes, one joint per door.
};

// Desc trees come in three kinds: joint, anim joint, mat anim joint.
enum {
    KIND_JOINT,
    KIND_ANIM,
    KIND_MATANIM,
};
typedef struct NodeKind {
    u32 size;
    u32 child;
    u32 next;
} NodeKind;
extern const NodeKind css_node_kinds[3];
#define CHILD(node, kind) (*(void **)((u8 *)(node) + css_node_kinds[kind].child))
#define NEXT(node, kind) (*(void **)((u8 *)(node) + css_node_kinds[kind].next))

HSD_JObj * css_child(HSD_JObj * root, int index);
// The node at DFS index *index, counting *index down along the way.
void * css_find_node(void * node, int kind, int * index);

#endif
