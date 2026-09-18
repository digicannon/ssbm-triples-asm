#include "css_door_text.h"

#include "css.h"

// Four SJIS dots: what the texts are sized for at init.
static const char placeholder[] = "\x81\x45\x81\x45\x81\x45\x81\x45";
static const char list_header[] = "\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45\x81\x45";
static const char name_entry[] = "\x82\x6d\x82\x60\x82\x6c\x82\x64\x20\x82\x64\x82\x6d\x82\x73\x82\x71\x82\x78"; // NAME ENTRY
static const GXColor yellow = {0xFF, 0xFF, 0, 0xFF};

// The CSS's own canvas is the latest font 0 one.
static int css_canvas() {
    int canvas = -1;
    for (const TextCanvas * c = text_canvases; c; c = c->next) {
        if (c->font == 0) ++canvas;
    }
    return canvas;
}

void css_door_text_create(HSD_JObj * anchor, CSSTagData * tag, const Player * player) {
    Text * text = Text_Create(0, css_canvas());
    text->x4c = text->default_fitting = text->default_alignment = 1;
    text->font_size_x = 0.058f;
    text->font_size_y = 0.055f;

    // The text fits itself to its box, so only the box is squeezed.  A
    // little wider than the vanilla 160 so long names fit the squeezed plate.
    f32 squeeze = css_child(css_scene_root, BG_JOINT)->scale[0];
    text->box_size_x = 162.0f * squeeze;
    text->box_size_y = 32.0f;

    f32 pos[3];
    JObj_WorldPos(anchor, NULL, pos);
    text->pos_x = pos[0] + 0.5f * squeeze;
    text->pos_y = -0.4f - pos[1];
    text->pos_z = 0.0f; // The plate's plane; the anchor's 0.4 drifts under perspective.

    Text_InitSubtext(text, 81.0f * squeeze, 0.0f, placeholder);
    // A tag in use is written once at CSS build; css_door_refresh leaves it.
    if (tag->use_tag) {
        Text_SetSubtext(text, 0, GetNameText(player->nametag));
        text->default_kerning = 0;
    }
    tag->text = text;
}

void css_door_list_place(HSD_JObj * window, HSD_JObj * anchor, Text * list) {
    f32 stretch = css_child(css_scene_root, BG_JOINT)->scale[0] * NAMETAG_WINDOW_STRETCH;
    f32 pos[3];
    JObj_WorldPos(window, NULL, pos);
    // The vanilla's 0.6 inside the window's left edge.
    list->pos_x = pos[0] + 0.6f * stretch;
    JObj_WorldPos(anchor, NULL, pos);
    list->pos_y = 0.8f - pos[1] - 1.0f;
    list->pos_z = pos[2];
    // Glyphs squeeze with the window; the box clips at its width times this.
    list->font_size_x = 0.065f * stretch;
}

void css_door_list_create(HSD_JObj * window, HSD_JObj * anchor, CSSTagData * tag) {
    Text * list = Text_Create(0, css_canvas());
    list->default_fitting = 1;
    list->box_size_x = 154.0f;
    list->box_size_y = 256.0f;
    list->font_size_y = 0.065f;
    list->x4e = 1;
    list->hidden = 1;
    css_door_list_place(window, anchor, list);
    Text_InitSubtext(list, 0.0f, 0.0f, list_header);
    Text_SetSubtextColor(list, 0, &yellow);
    Text_InitSubtext(list, 0.0f, 0.0f, name_entry);
    Text_SetSubtextColor(list, 1, &yellow);
    for (int i = 0; i < 9; ++i) Text_InitSubtext(list, 10.0f, 0.0f, placeholder);
    tag->name_ls = list;
}

void css_door_texts_remake() {
    for (int i = 0; i < 4; ++i) {
        css_tags[i].data->text->hidden = 1;
        css_door_text_create(css_child(css_scene_root, 0x74 + 5 * i), css_tags[i].data, &players[i]);
        css_door_list_place(css_child(css_scene_root, NAMETAG_WINDOW_JOINT + 5 * i), css_child(css_scene_root, 0x73 + 5 * i), css_tags[i].data->name_ls);
        css_door_refresh(i);
    }
}
