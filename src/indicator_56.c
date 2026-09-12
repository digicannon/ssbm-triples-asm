#include "melee.h"
#include "triples.h"

extern const u8 indicator_5_us[];
extern const u8 indicator_6_us[];
extern const u8 indicator_5_jp[];
extern const u8 indicator_6_jp[];

#define IMAGE_COUNT 7 // CP, P1-P4, blank, heart.
#define IMAGE_P1 1

#define FRAME_RED 0
#define FRAME_BLUE 1
#define FRAME_YELLOW 2
#define FRAME_GREEN 3

#define TEAM_RED 0
#define TEAM_BLUE 1
#define TEAM_GREEN 2

static const GXColor colors[2] = {P5_COLOR, P6_COLOR};

static const HSD_ImageDesc labels[2][2] = {
    {{(u8 *)indicator_5_jp, 32, 44, GX_TF_IA4}, {(u8 *)indicator_6_jp, 32, 44, GX_TF_IA4}},
    {{(u8 *)indicator_5_us, 32, 44, GX_TF_IA4}, {(u8 *)indicator_6_us, 32, 44, GX_TF_IA4}},
};

f32 indicator_56_frame(int team, bool teams) {
    if (teams) {
        if (team == TEAM_GREEN) return FRAME_GREEN;
        return team;
    }

    return FRAME_RED;
}

static bool showing_nametag(const HSD_DObj * label) {
    const HSD_TObj * tobj = label->mobj->tobj;
    return tobj->imagedesc != tobj->imagetbl[IMAGE_P1];
}

void indicator_56_recolor(HSD_JObj * root, int slot) {
    if (css_is_teams || Player_GetPlayerSlotType(slot) != PKIND_HUMAN) {
        return;
    }

    GXColor color = colors[slot - 4];
    HSD_DObj * label = root->child->dobj;
    HSD_DObj * arrow = label->next;
    HSD_DObj * backdrop = arrow->next;

    arrow->mobj->mat->diffuse = color;

    if (!showing_nametag(label)) {
        label->mobj->mat->diffuse = color;
    }

    backdrop->mobj->mat->diffuse.r = (color.r * 48) / 255;
    backdrop->mobj->mat->diffuse.g = (color.g * 48) / 255;
    backdrop->mobj->mat->diffuse.b = (color.b * 48) / 255;
}

void indicator_56_label(HSD_JObj * root, int slot) {
    if (Player_GetPlayerSlotType(slot) != PKIND_HUMAN) return;

    indicator_56_recolor(root, slot);

    if (showing_nametag(root->child->dobj)) {
        return;
    }

    HSD_TObj * tobj = root->child->dobj->mobj->tobj;
    HSD_ImageDesc * label = (HSD_ImageDesc *)&labels[lbLang_IsSavedLanguageUS()][slot - 4];
    HSD_ImageDesc ** images = HSD_MemAlloc(IMAGE_COUNT * sizeof(*images));
    memcpy(images, tobj->imagetbl, IMAGE_COUNT * sizeof(*images));
    images[IMAGE_P1] = label;
    tobj->imagetbl = images;
    tobj->imagedesc = label;
}
