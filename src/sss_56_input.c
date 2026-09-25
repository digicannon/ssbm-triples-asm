#include "triples.h"

#define ANY_PORT -1
#define DEADZONE 30

static bool deflected(s8 x, s8 y) {
    return x < -DEADZONE || x > DEADZONE || y < -DEADZONE || y > DEADZONE;
}

void sss_56_input() {
    if (sss_input_port != ANY_PORT) {
        return;
    }

    for (int i = 0; i < 2; ++i) {
        const PadStatus * pad = &triples_converted_output[i];
        sss_input_trigger |= pad->trigger;
        if (!deflected(sss_input_stick_x, sss_input_stick_y) && deflected(pad->stick_x, pad->stick_y)) {
            sss_input_stick_x = pad->stick_x;
            sss_input_stick_y = pad->stick_y;
        }
    }
}

// After mnStageSel_Scene_OnFrame's existing pad loop.
HOOK(0x8025BA60,
    "bl sss_56_input\n"
    "lbz r3, -0x49F4(r13)"); // Original code.
