#include "css.h"

const NodeKind css_node_kinds[3] = {{0x40, 8, 0xC}, {0x14, 0, 4}, {0xC, 0, 4}};

HSD_JObj * css_child(HSD_JObj * root, int index) {
    HSD_JObj * out = NULL;
    JObj_GetChild(root, &out, index, -1);
    return out;
}

void * css_find_node(void * node, int kind, int * index) {
    if (!node || *index == 0) return node;
    --*index;
    void * found = css_find_node(CHILD(node, kind), kind, index);
    return found ? found : css_find_node(NEXT(node, kind), kind, index);
}
