#include "melee.h"
#include "triples.h"

#define SUB_COLOR_VANILLA_TINTS 3
#define SUB_COLOR_PORT 6 // Plus the port.
#define SUB_COLOR_TEAM (SUB_COLOR_PORT + GM_MAX_PLAYERS) // Plus TEAM_TINTS * team, light then dark.
#define TEAM_COUNT 3
#define TEAM_TINTS 2

#define TINT_PORT_STRENGTH 0x60
#define TINT_TEAM_STRENGTH 0x90

#define STRINGIFY(x) #x
#define ASM_VALUE(x) STRINGIFY(x)

GXColor match_sub_color_tints[GM_MAX_PLAYERS + (TEAM_COUNT * TEAM_TINTS)] = {
    // --- Free for all. ---
    {0xFF, 0x30, 0x30}, // P1.
    {0x30, 0x30, 0xFF}, // P2.
    {0xFF, 0xD0, 0x20}, // P3.
    {0x20, 0xC0, 0x20}, // P4.
    P5_COLOR,
    P6_COLOR,
    // --- Teams. ---
    {0xFF, 0x60, 0x60}, // Red light.
    {0x80, 0x00, 0x00}, // Red dark.
    {0x60, 0x60, 0xFF}, // Blue light.
    {0x00, 0x00, 0x80}, // Blue dark.
    {0x60, 0xFF, 0x60}, // Green light.
    {0x00, 0x80, 0x00}, // Green dark.
};

static bool is_duplicate(const StartMeleeData * start, int port, int other_port) {
    const Player * player = &start->players[port];
    const Player * other = &start->players[other_port];

    if (port == other_port) {
        return false;
    }

    if (player->slot_type == PKIND_CLOSED || other->slot_type == PKIND_CLOSED) {
        return false;
    }

    if (player->ckind != other->ckind) {
        return false;
    }

    if (start->is_teams) {
        return (player->team == other->team);
    } else {
        return (player->color == other->color);
    }
}

void setup_match_sub_colors(StartMeleeData * start) {
    for (int port = 0; port < GM_MAX_PLAYERS; ++port) {
        match_sub_color_tints[port].a = TINT_PORT_STRENGTH;

        for (int other_port = 0; other_port < GM_MAX_PLAYERS; ++other_port) {
            if (!is_duplicate(start, port, other_port)) {
                continue;
            }

            Player * other = &start->players[other_port];

            if (!start->is_teams) {
                other->sub_color = SUB_COLOR_PORT + other_port;
            } else if (start->players[port].sub_color == other->sub_color) {
                ++other->sub_color;
            }
        }
    }

    if (!start->is_teams) {
        return;
    }

    // In teams, duplicates past the vanilla light/dark tint get team color tints.

    for (int port = 0; port < GM_MAX_PLAYERS; ++port) {
        Player * player = &start->players[port];

        if (player->sub_color < SUB_COLOR_VANILLA_TINTS) {
            continue;
        }

        int shade = player->sub_color - SUB_COLOR_VANILLA_TINTS;
        int team_tint = (player->team * TEAM_TINTS) + shade;
        player->sub_color = SUB_COLOR_TEAM + team_tint;
        match_sub_color_tints[GM_MAX_PLAYERS + team_tint].a = TINT_TEAM_STRENGTH;
    }
}

HOOK(0x801B0348, "b setup_match_sub_colors");

// Replace subcolor on fighter init.
// r0 holds existing subcolor - 1.
HOOK(0x80068A5C,
    "cmpwi r0, " ASM_VALUE(SUB_COLOR_PORT) " - 1\n"
    "blt tint_create_vanilla\n"
    "load r3, match_sub_color_tints - (" ASM_VALUE(SUB_COLOR_PORT) " - 1) * 4\n"
    "rlwinm r0, r0, 2, 0, 29\n"
    "add r3, r3, r0\n"
    "b tint_create_done\n"
"tint_create_vanilla:\n"
    "add r3, r4, r3\n" // Original code.
"tint_create_done:");

// Replace subcolor on fighter render.
// r5 holds existing subcolor, or 4 and 5 for metal and the like.
HOOK(0x800BF8B8,
    "cmpwi r5, " ASM_VALUE(SUB_COLOR_PORT) "\n"
    "blt tint_material_vanilla\n"
    "load r3, match_sub_color_tints - " ASM_VALUE(SUB_COLOR_PORT) " * 4\n"
    "rlwinm r0, r5, 2, 0, 29\n"
    "lwzx r0, r3, r0\n"
    "b tint_material_done\n"
"tint_material_vanilla:\n"
    "lwz r0, 0x6D8(r3)\n" // Original code.
"tint_material_done:");