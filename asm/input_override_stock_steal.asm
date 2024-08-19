# ====================
#  Insert at 8016BA0C
# ====================

.include "triples.s"

# Button word should be returned in r0.

# Registers.
.set player_idx, 31

    # Only run for players 5 and 6.
    cmpli 0, player_idx, 4
    blt return

    # Make player 5 index 0.
    subi r0, player_idx, 4
    # Multiply by size of input struct.
    mulli r0, r0, 0x44
    
    # Construct address to input struct.
    lis r3, triples_converted_output @h
    ori r3, r3, triples_converted_output @l
    add r3, r3, r0

return:
    lwz r0, 8(r3)
