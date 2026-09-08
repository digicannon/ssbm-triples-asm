.ifndef COMMON_H
.set COMMON_H, 1

################################################################################
# Macros
################################################################################
.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadwz reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
lwz \reg, 0(\reg)
.endm

.macro loadbz reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
lbz \reg, 0(\reg)
.endm

# This is where the free space in our stack frame starts
.set BKP_FREE_SPACE_OFFSET, 8

# The default free space such that we don't break any legacy codes, includes the location where
# the non-volatile registers were stored as well as the 0x78 of free space that used to exist.
# Now it's all just free space
.set BKP_DEFAULT_FREE_SPACE_SIZE, 0xA8
.set BKP_DEFAULT_FREG, 0
.set BKP_DEFAULT_REG, 12

# backup is used to set up a stack frame in which LR and non-volatile registers will be stored.
# It also sets up some free space on the stack for the function to use if needed.
# More info: https://docs.google.com/document/d/1QJOQzy933fxpfzIJlq6xopcviZ5tALKQvi_OOqpjehE
.macro backup free_space=BKP_DEFAULT_FREE_SPACE_SIZE, num_freg=BKP_DEFAULT_FREG, num_reg=BKP_DEFAULT_REG
mflr r0
stw r0, 0x4(r1)
# Stack allocation has to be 4-byte aligned otherwise it crashes on console. This section
# makes space for the back chain, LR, non-volatile registers, and free space
.if \free_space % 4 == 0
  .set ALIGNED_FREE_SPACE, \free_space
.else
  .set ALIGNED_FREE_SPACE, \free_space + (4 - \free_space % 4)
.endif
stwu r1,-(0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * \num_freg)(r1)
.if \num_reg > 0
  stmw 32 - \num_reg, (0x8 + ALIGNED_FREE_SPACE)(r1)
.endif
.if \num_freg > 0
  stfd f31, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 0)(r1)
.endif
.if \num_freg > 1
  stfd f30, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 1)(r1)
.endif
.if \num_freg > 2
  stfd f29, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 2)(r1)
.endif
.if \num_freg > 3
  stfd f28, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 3)(r1)
.endif
.if \num_freg > 4
  stfd f27, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 4)(r1)
.endif
.if \num_freg > 5
  stfd f26, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 5)(r1)
.endif
.if \num_freg > 6
  stfd f25, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 6)(r1)
.endif
.if \num_freg > 7
  stfd f24, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 7)(r1)
.endif
.if \num_freg > 8
  stfd f23, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 8)(r1)
.endif
.if \num_freg > 9
  stfd f22, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 9)(r1)
.endif
.if \num_freg > 10
  stfd f21, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 10)(r1)
.endif
.if \num_freg > 11
  stfd f20, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 11)(r1)
.endif
.if \num_freg > 12
  stfd f19, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 12)(r1)
.endif
.if \num_freg > 13
  stfd f18, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 13)(r1)
.endif
.if \num_freg > 14
  stfd f17, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 14)(r1)
.endif
.if \num_freg > 15
  stfd f16, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 15)(r1)
.endif
.if \num_freg > 16
  stfd f15, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 16)(r1)
.endif
.if \num_freg > 17
  stfd f14, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 17)(r1)
.endif
.endm

.macro restore free_space=BKP_DEFAULT_FREE_SPACE_SIZE, num_freg=BKP_DEFAULT_FREG, num_reg=BKP_DEFAULT_REG
# Stack allocation has to be 4-byte aligned otherwise it crashes on console
.if \free_space % 4 == 0
  .set ALIGNED_FREE_SPACE, \free_space
.else
  .set ALIGNED_FREE_SPACE, \free_space + (4 - \free_space % 4)
.endif
.if \num_reg > 0
  lmw 32 - \num_reg, (0x8 + ALIGNED_FREE_SPACE)(r1)
.endif
.if \num_freg > 0
  lfd f31, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 0)(r1)
.endif
.if \num_freg > 1
  lfd f30, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 1)(r1)
.endif
.if \num_freg > 2
  lfd f29, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 2)(r1)
.endif
.if \num_freg > 3
  lfd f28, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 3)(r1)
.endif
.if \num_freg > 4
  lfd f27, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 4)(r1)
.endif
.if \num_freg > 5
  lfd f26, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 5)(r1)
.endif
.if \num_freg > 6
  lfd f25, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 6)(r1)
.endif
.if \num_freg > 7
  lfd f24, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 7)(r1)
.endif
.if \num_freg > 8
  lfd f23, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 8)(r1)
.endif
.if \num_freg > 9
  lfd f22, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 9)(r1)
.endif
.if \num_freg > 10
  lfd f21, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 10)(r1)
.endif
.if \num_freg > 11
  lfd f20, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 11)(r1)
.endif
.if \num_freg > 12
  lfd f19, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 12)(r1)
.endif
.if \num_freg > 13
  lfd f18, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 13)(r1)
.endif
.if \num_freg > 14
  lfd f17, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 14)(r1)
.endif
.if \num_freg > 15
  lfd f16, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 15)(r1)
.endif
.if \num_freg > 16
  lfd f15, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 16)(r1)
.endif
.if \num_freg > 17
  lfd f14, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * 17)(r1)
.endif
lwz r0, (0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * \num_freg + 0x4)(r1)
addi r1, r1, 0x8 + ALIGNED_FREE_SPACE + 0x4 * \num_reg + 0x8 * \num_freg	# release the space
mtlr r0
.endm

.endif
