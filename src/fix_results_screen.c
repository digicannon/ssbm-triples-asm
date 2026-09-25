#include "triples.h"

#define RESULTS_PLAYER_CPU 1
#define RESULTS_PLAYER_NONE 3
#define RESULTS_LAST_PLACE 3

static bool active(const ResultsPlayer * player) {
    return player->player_type != RESULTS_PLAYER_NONE;
}

static bool won(const ResultsPlayer * player, u8 winning_team) {
    if (css_is_teams) {
        return player->team == winning_team;
    } else {
        return player->placement == 0;
    }
}

static void replace(ResultsPlayer * dst, const ResultsPlayer * src) {
    memcpy(dst, src, sizeof(*dst));
    dst->player_type = RESULTS_PLAYER_CPU;
}

/** Tries to find, in order:
    - Empty slot.
    - Lowest placing loser.
    If nothing is found, returns NULL. */
static ResultsPlayer * find_replacement(u8 winning_team) {
    ResultsPlayer * worst = NULL;
    for (int i = 0; i < 4; ++i) {
        ResultsPlayer * player = &results_players[i];

        if (!active(player)) {
            return player;
        }

        if (!won(player, winning_team) && (worst == NULL || player->placement > worst->placement)) {
            worst = player;
        }
    }
    return worst;
}

static void copy_winners_56() {
    ResultsPlayer * r = results_players;

    u8 winning_team = 0;
    for (int i = 0; i < GM_MAX_PLAYERS; ++i) {
        if (active(&r[i]) && r[i].placement == 0) {
            winning_team = r[i].team;
            break;
        }
    }

    for (int i = 4; i < GM_MAX_PLAYERS; ++i) {
        if (!active(&r[i]) || !won(&r[i], winning_team)) {
            continue;
        }

        ResultsPlayer * dest = find_replacement(winning_team);
        if (dest) {
            replace(dest, &r[i]);
        } else {
            break;
        }
    }
}

// The results screen has four slots and crashes on P5/P6 or a placement past 4th.
void fix_results_screen() {
    for (int i = 0; i < GM_MAX_PLAYERS; ++i) {
        ResultsPlayer * player = &results_players[i];
        if (player->placement > RESULTS_LAST_PLACE) {
            player->placement = RESULTS_LAST_PLACE;
            player->sub_placement = RESULTS_LAST_PLACE;
        }
    }

    copy_winners_56();

    for (int i = 4; i < GM_MAX_PLAYERS; ++i) {
        memset(&results_players[i], 0, sizeof(results_players[i]));
        results_players[i].player_type = RESULTS_PLAYER_NONE;
    }
}

HOOK(0x8016EBA8,
    "bl fix_results_screen\n"
    "lwz r0, 0x1C(r1)"); // Original code.
