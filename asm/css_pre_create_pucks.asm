# Insert at 80264D80
# Clear the puck data pointers for P5 and P6.
# r3, r4, r5 are free.

.include "Common.s"
.include "triples.s"

    li r3, 0

    load r4, triples_puck_data_p5
    stw r3, 0(r4)
    load r4, triples_puck_data_p6
    stw r3, 0(r4)

    # Original instruction.
    li r22, 0
