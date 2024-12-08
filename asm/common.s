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

################################################################################
# Static Function Locations
################################################################################

.set ZeroAreaLength,0x8000c160

## HSD functions
.set HSD_Randi,0x80380580
.set HSD_MemAlloc,0x8037f1e4
.set HSD_Free,0x8037f1b0
.set HSD_PadFlushQueue,0x80376d04
.set HSD_StartRender,0x80375538
.set HSD_VICopyXFBASync,0x803761c0
.set HSD_PerfSetStartTime,0x8037E214
.set HSD_PadRumbleActiveID,0x80378430
.set HSD_ArchiveGetPublicAddress, 0x80380358

## GObj functions
.set GObj_Create,0x803901f0 #(obj_type,subclass,priority)
.set GObj_AddUserData,0x80390b68 #void (*GObj_AddUserData)(GOBJ *gobj, int userDataKind, void *destructor, void *userData) = (void *)0x80390b68;
.set GObj_Destroy,0x80390228
.set GObj_AddProc,0x8038fd54 # (obj,func,priority)
.set GObj_RemoveProc,0x8038fed4
.set GObj_AddToObj,0x80390A70 #(gboj,obj_kind,obj_ptr)
.set GObj_SetupGXLink, 0x8039069c #(gobj,function,gx_link,priority)

## AObj Functions
.set AObj_SetEndFrame, 0x8036532C #(aobj, frame)

## JObj Functions
.set JObj_GetJObjChild,0x80011e24
.set JObj_RemoveAnimAll,0x8036f6b4
.set JObj_LoadJoint, 0x80370E44 #(jobj_desc_ptr)
.set JObj_AddAnim, 0x8036FA10 # (jobj,an_joint,mat_joint,sh_joint)
.set JObj_AddAnimAll, 0x8036FB5C # (jobj,an_joint,mat_joint,sh_joint)
.set JObj_ReqAnim, 0x8036F934 #(HSD_JObj* jobj, f32 frame)
.set JObj_ReqAnimAll, 0x8036F8BC #(HSD_JObj* jobj, f32 frame)
.set JObj_Anim, 0x80370780 #(jobj)
.set JObj_AnimAll, 0x80370928 #(jobj)
.set JObj_ClearFlags, 0x80371f00 #(jobj,flags)
.set JObj_ClearFlagsAll, 0x80371F9C #(jobj,flags)
.set JObj_SetFlags, 0x80371D00 # (jobj,flags)
.set JObj_SetFlagsAll, 0x80371D9c # (jobj,flags)

## Text functions
.set Text_AllocateMenuTextMemory,0x803A5798
.set Text_FreeMenuTextMemory,0x80390228 # Not sure about this one, but it has a similar behavior to the Allocate
.set Text_CreateStruct,0x803a6754
.set Text_AllocateTextObject,0x803a5acc
.set Text_CopyPremadeTextDataToStruct,0x803a6368# (text struct, index on open menu file, cannot be used, jackpot=will change to memory address we want)
.set Text_InitializeSubtext,0x803a6b98
.set Text_UpdateSubtextSize,0x803a7548
.set Text_ChangeTextColor,0x803a74f0
.set Text_DrawEachFrame,0x803a84bc
.set Text_UpdateSubtextContents,0x803a70a0
.set Text_RemoveText,0x803a5cc4

## EXI functions
.set EXIAttach,0x803464c0
.set EXILock,0x80346d80
.set EXISelect,0x80346688
.set EXIDma,0x80345e60
.set EXISync,0x80345f4c
.set EXIDeselect,0x803467b4
.set EXIUnlock,0x80346e74
.set EXIDetach,0x803465cc

## Nametag data functions
.set Nametag_LoadSlotText,0x8023754c
.set Nametag_SetNameAsInUse,0x80237a04
.set Nametag_GetNametagBlock,0x8015cc9c

## VI/GX functions
.set GXInvalidateVtxCache,0x8033c898
.set GXInvalidateTexAll,0x8033f270
.set VIWaitForRetrace,0x8034f314
.set VISetBlack,0x80350100

.set OSDisableInterrupts, 0x80347364
.set OSRestoreInterrupts, 0x8034738c
.set OSCancelAlarm, 0x80343aac
.set InsertAlarm, 0x80343778

## Common/memory management
.set va_arg, 0x80322620
.set OSReport,0x803456a8
.set memcpy,0x800031f4
.set memcmp,0x803238c8
.set strcpy,0x80325a50
.set strlen,0x80325b04
.set sprintf,0x80323cf4
.set Zero_AreaLength,0x8000c160
.set TRK_flush_cache,0x80328f50
.set FileLoad_ToPreAllocatedSpace,0x80016580
.set DiscError_ResumeGame,0x80024f6c

## PlayerBlock/game-state related functions
.set PlayerBlock_LoadStaticBlock,0x80031724
.set PlayerBlock_UpdateCoords,0x80032828
.set PlayerBlock_LoadExternalCharID,0x80032330
.set PlayerBlock_LoadRemainingStocks,0x80033bd8
.set PlayerBlock_LoadSlotType,0x8003241c
.set PlayerBlock_LoadDataOffsetStart,0x8003418c
.set PlayerBlock_LoadTeamID,0x80033370
.set PlayerBlock_StoreInitialCoords,0x80032768
.set PlayerBlock_LoadPlayerXPosition,0x800326cc
.set PlayerBlock_UpdateFacingDirection,0x80033094
.set PlayerBlock_LoadMainCharDataOffset,0x80034110
.set SpawnPoint_GetXYZFromSpawnID,0x80224e64
.set Damage_UpdatePercent,0x8006cc7c
.set MatchEnd_GetWinningTeam,0x801654a0

## Camera functions
.set Camera_UpdatePlayerCameraBox,0x800761c8
.set Camera_CorrectPosition,0x8002f3ac

## Audio/SFX functions
.set SFX_StopSFXInstance, 0x800236b8
.set Audio_AdjustMusicSFXVolume,0x80025064
.set SFX_Menu_CommonSound,0x80024030
.set SFX_PlaySoundAtFullVolume, 0x800237a8 #SFX_PlaySoundAtFullVolume(r3=soundid,r4=volume?,r5=priority)

## Scene/input-related functions
.set NoContestOrRetry_,0x8016cf4c
.set fetchAnimationHeader,0x80085fd4
.set Damage_UpdatePercent,0x8006cc7c
.set Obj_ChangeRotation_Yaw,0x8007592c
.set MenuController_ChangeScreenMinor,0x801a4b60
.set SinglePlayerModeCheck,0x8016b41c
.set CheckIfGameEnginePaused,0x801a45e8
.set Inputs_GetPlayerHeldInputs,0x801a3680
.set Inputs_GetPlayerInstantInputs,0x801A36A0
.set Rumble_StoreRumbleFlag,0x8015ed4c
.set Audio_AdjustMusicSFXVolume,0x80025064
.set DiscError_ResumeGame,0x80024f6c
.set RenewInputs_Prefunction,0x800195fc
.set PadAlarmCheck,0x80019894
.set Event_StoreSceneNumber,0x80229860
.set EventMatch_Store,0x801beb74
.set PadRead,0x8034da00

.endif
