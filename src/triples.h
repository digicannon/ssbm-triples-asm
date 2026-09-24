#ifndef TRIPLES_H
#define TRIPLES_H

#include "melee.h"

__asm__(".include \"../asm/common.s\"");

/// css_name_entry_slot value while P5/P6 has the keyboard.
#define CSS_NAME_ENTRY_SLOT_56 4

#define P5_COLOR {0xCC, 0x7A, 0x1E, 0xFF}
#define P6_COLOR {0x98, 0x4C, 0xE5, 0xFF}

// One port of the GameCube adapter's USB report.
typedef struct AdapterPort {
    u8 status;
    u8 buttons;
    u8 buttons2;
    u8 stick_x;
    u8 stick_y;
    u8 cstick_x;
    u8 cstick_y;
    u8 trigger_left;
    u8 trigger_right;
} AdapterPort;
ASSERT_SIZE(AdapterPort, 9);

typedef struct AdapterReport {
    u8 id;
    AdapterPort port[4];
} AdapterReport;

// Nintendont's HID device, as it publishes it to the game.
typedef struct HidControl {
    u32 vid;
    u32 pid;
} HidControl;

// Our adapter ports as raw pads for the pad loop, and what it takes to
// make them.
typedef struct AdapterPads {
    PADStatus pad[2];
    AdapterPort origin[2];
    bool plugged[2];
} AdapterPads;
ASSERT_OFFSET(AdapterPads, pad, 0);

// Nintendont's HID data in Wii memory.
extern u32 hid_status;
extern HidControl hid_ctrl;
extern AdapterReport hid_report;
extern u32 hid_motor_56;

extern AdapterPads adapter_pads_data;
extern PadStatus triples_converted_output[2];
extern u32 css_name_entry_port;

int color_brightness(GXColor color, int * darkness_out);
GXColor color_hue(GXColor color);
GXColor color_retint(GXColor hue, GXColor sat_bright_source);

#endif
