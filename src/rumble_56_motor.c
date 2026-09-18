#include "melee.h"

#define RUMBLE_STATUS_ON 2

void rumble_56_motor(int port, u8 status) {
    u32 bit = 1 << (port - 4);
    hid_motor_56 = status == RUMBLE_STATUS_ON ? hid_motor_56 | bit : hid_motor_56 & ~bit;
    DCFlushRange(&hid_motor_56, sizeof(hid_motor_56));
}
