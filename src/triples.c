#include "triples.h"

int color_brightness(GXColor color, int * darkness_out) {
    const u8 * rgb = &color.r;

    int low = rgb[0];
    int high = rgb[0];
    for (int i = 1; i < 3; ++i) {
        if (rgb[i] < low) low = rgb[i];
        if (rgb[i] > high) high = rgb[i];
    }

    if (darkness_out) {
        *darkness_out = low;
    }

    return high;
}

GXColor color_hue(GXColor color) {
    u8 * rgb = &color.r;
    int low;
    int high = color_brightness(color, &low);
    for (int i = 0; i < 3; ++i) {
        rgb[i] = (rgb[i] - low) * 0xFF / (high - low);
    }
    return color;
}

GXColor color_retint(GXColor hue, GXColor sat_bright_source) {
    u8 * rgb = &sat_bright_source.r;
    const u8 * h = &hue.r;

    int low;
    int high = color_brightness(sat_bright_source, &low);
    for (int i = 0; i < 3; ++i) {
        rgb[i] = low + h[i] * (high - low) / 0xFF;
    }

    return sat_bright_source;
}
