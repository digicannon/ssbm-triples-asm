#To be inserted at 8016e510
.include "common.s"


.set MatchInfo,31
.set SpawnTable,30
.set REG_PlayerSlot,28

backup

#Don't run in singleplayer
  branchl r12,0x8016b41c
  cmpwi r3,0
  bne Exit

#Check if teams
  #lbz	r3, 0x24D0 (MatchInfo)
  #cmpwi r3,1
  #bne Exit

#Create an array
CreateTeamArray:
.set REG_TeamID,25
.set REG_TeamArray,26
.set REG_ArraySize,24
  li  REG_TeamID,0
  addi  REG_TeamArray,sp,0x80
  li  REG_ArraySize,0
CreateTeamArray_Loop:
#Check how many players are on this team
  CheckTeam:
  .set REG_Count,23
  .set REG_TeamMembers,22
    li  REG_TeamMembers,0
    li  REG_Count,0
  CheckTeam_Loop:
  #Load slot type
    mr  r3,REG_Count
    branchl r12,PlayerBlock_LoadSlotType
    cmpwi r3,0x3
    beq CheckTeam_IncLoop      #If =3, no player present
  #Get Team
    mr  r3,REG_Count
    branchl r12,0x80033370
    cmpw  r3,REG_TeamID
    bne CheckTeam_IncLoop
  #Add to array
    stbx  REG_Count,REG_ArraySize,REG_TeamArray
    addi  REG_ArraySize,REG_ArraySize,1
  CheckTeam_IncLoop:
    addi  REG_Count,REG_Count,1
    cmpwi REG_Count,6
    blt CheckTeam_Loop
CreateTeamArray_IncLoop:
  addi  REG_TeamID,REG_TeamID,1
  cmpwi REG_TeamID,3
  blt CreateTeamArray_Loop

#Now search for this players ID
SearchForPlayerID:
.set  REG_Count,25
  li  REG_Count,0
SearchForPlayerID_Loop:
  lbzx  r3,REG_Count,REG_TeamArray
  cmpw  r3,REG_PlayerSlot
  beq SearchForPlayerID_Exit
SearchForPlayerID_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt SearchForPlayerID_Loop
SearchForPlayerID_Exit:
  bl get_match_player_count
  mr r4, REG_Count
  cmpli 0, r3, 5
  bge SearchForPlayerID_SetSpawn # Use triples spawns.
  # Adjust for doubles.
  cmpli 0, REG_Count, 2
  blt SearchForPlayerID_SetSpawn
  addi r4, r4, 1 # Skip 3rd spawn.
SearchForPlayerID_SetSpawn:
  mr  r3,REG_PlayerSlot
  lbz	r5, 0x24D0 (MatchInfo)
  bl  SetSpawn
  b Exit
#endregion

#region SetSpawn
SetSpawn:
.set  REG_PlayerSlot,31
.set  REG_SpawnID,30
.set  REG_IsTeams,29
.set  REG_SpawnTable,28

#Init
  backup
  mr  REG_PlayerSlot,r3
  mr  REG_SpawnID,r4
  mr  REG_IsTeams,r5

#Get Neutral Spawn Table
  bl NeutralSpawnTable
  mflr REG_SpawnTable

#Get stage ID
  lwz		r6,-0x6CB8 (r13)
  li    r5,0
#Get stage's spawn info
SetSpawn_StageSearchLoop:
  lwz   r3,StageID(REG_SpawnTable)            #get stage ID
  cmpwi r3,-1                     #check for end of table
  beq   SetSpawn_NotFound
  cmpw  r3,r6             #check for matching stage ID
  beq SetSpawn_FoundStage
  addi  REG_SpawnTable,REG_SpawnTable,EntryLength
  b SetSpawn_StageSearchLoop

SetSpawn_FoundStage:
#Get Players Spawn Point and Facing Direction Pointer
  addi REG_SpawnTable,REG_SpawnTable,SpawnData      #Skip past stage ID
  mulli r3,REG_IsTeams,SpawnDataLength
  add REG_SpawnTable,REG_SpawnTable,r3              #Get to teams/singles data
  mulli r3,REG_SpawnID,SpawnDataLengthPerPlayer     #Get to this players data
  add REG_SpawnTable,REG_SpawnTable,r3

#Set players new spawn coordinates
  addi  r4,sp,0x80
  lfs f1,SpawnX(REG_SpawnTable)
  stfs  f1,0x0(r4)
  lfs f1,SpawnY(REG_SpawnTable)
  stfs  f1,0x4(r4)
  li  r3,0
  stw  r3,0x8(r4)
  mr  r3,REG_PlayerSlot
  branchl r12,0x80032768
  b SetSpawn_UpdateFacingDirection

SetSpawn_NotFound:
#If singles, use spawn order
  cmpwi REG_IsTeams,1
  beq SetSpawn_NotFound_Teams
  mr  r3,REG_SpawnID
  b SetSpawn_NotFound_UpdatePosition
SetSpawn_NotFound_Teams:
  bl  NeutralSpawnTable_NotFound
  mflr  r3
  lbzx  r3,r3,REG_SpawnID
  b SetSpawn_NotFound_UpdatePosition
SetSpawn_NotFound_UpdatePosition:
#Get XYZ from spawn ID
  addi  r4,sp,0x80
  branchl r12,0x80224e64
#Set new XYZ spawn
  mr  r3,REG_PlayerSlot
  addi  r4,sp,0x80
  branchl r12,0x80032768
  b SetSpawn_UpdateFacingDirection

SetSpawn_UpdateFacingDirection:
#Load X Position
  mr  r3,REG_PlayerSlot
  addi  r4,sp,0x80
  branchl r12,0x800326cc
  lfs f1,0x80(sp)
#Compare to 0
  lfs	f0, -0x5718 (rtoc)
  fcmpo cr0,f1,f0
  ble SetSpawn_UpdateFacingDirection_FacingRight
SetSpawn_UpdateFacingDirection_FacingLeft:
  lfs	f1, -0x5708 (rtoc)
  b SetSpawn_UpdateFacingDirection_Store
SetSpawn_UpdateFacingDirection_FacingRight:
  lfs	f1, -0x5734 (rtoc)
SetSpawn_UpdateFacingDirection_Store:
#Update Facing Direction
  mr  r3,REG_PlayerSlot
  branchl r12,0x80033094

SetSpawn_AdjustEntryFrames:
  mr  r3,REG_PlayerSlot
  mulli r4,REG_SpawnID,5
  branchl r12,0x80035fdc

SetSpawn_Exit:
  restore
  blr
#endregion

get_match_player_count:
.set player_block, 0x80453080
.set player_block_size, 0xE90
.set reg_player_count, 3
.set reg_player, 4
  li reg_player_count, 0
  load reg_player, player_block
get_match_player_count.loop:
  # Offset 8 is player type, uint32.  Check != 3 (NONE).
  lwz r5, 8(reg_player)
  cmpli 0, r5, 3
  beq get_match_player_count.control
  # This player is active.
  addi reg_player_count, reg_player_count, 1
get_match_player_count.control:
  addi reg_player, reg_player, player_block_size
  # while (player_block <= player_block_p6)
  load r5, (player_block + (player_block_size * 5))
  cmpl 0, reg_player, r5
  ble get_match_player_count.loop
  blr

######################
NeutralSpawnTable:
blrl
.set  EntryLength, 0x4 + SpawnDataLength * 2
.set  SpawnDataLength, 0x8 * 6
.set  SpawnDataLengthPerPlayer, 0x8

.set  StageID,0x0
.set  SpawnData,0x4
  .set  SpawnX,0x0
  .set  SpawnY,0x4

# Stages are identified by their external ID.

# Fountain of Dreams
# Only here to allow singles/doubles.  Don't bother making real 5/6 spawns.
.long 0x02
  #Singles Data
    .float -41.25,21
    .float 41.25,27
    .float 0,5.25
    .float 0,48
    .float 0,48
    .float 0,48
  #Teams Data
    .float -41.25,21
    .float -41.25,5
    .float -41.25,5
    .float 41.25,27
    .float 41.25,5
    .float 41.25,5
# Pokemon Stadium
.long 0x03
  #Singles Data
    .float -40,32
    .float 40,32
    .float 70,7
    .float -70,7
    .float -40,5
    .float 40,5
  #Teams Data
    .float -40,32
    .float -40,5
    .float -70,5
    .float 40,32
    .float 40,5
    .float 70,5
# Peach's Castle
.long 0x04
  # Singles Data
    .float -60,90
    .float 60,90
    .float -40,90
    .float 40,90
    .float -80,85
    .float 80,85
  # Teams Data
    .float -60,90
    .float -40,90
    .float -80,85
    .float 60,90
    .float 40,90
    .float 80,85
# Kongo Jungle
.long 0x05
  # Singles Data
    .float -32,0
    .float 32,0
    .float -32,26
    .float 32,40
    .float -32,60
    .float 32,69
  # Teams Data
    .float -32,0
    .float -32,26
    .float -32,60
    .float 32,0
    .float 32,40
    .float 32,69
# Brinstar
.long 0x06
  # Singles Data
    .float -30,5
    .float 26,5
    .float -60,32
    .float 58,25
    .float -50,5
    .float 50,0
  # Teams Data
    .float -30,5
    .float -60,32
    .float -50,5
    .float 26,5
    .float 58,25
    .float 50,0
# Corneria
.long 0x07
  #Singles Data
    .float -110,298
    .float 30,332
    .float -85,294
    .float 75,278
    .float -60,290
    .float 110,280
  #Teams Data
    .float -110,298
    .float -85,294
    .float -60,290
    .float 30,332
    .float 75,278
    .float 110,280
# Yoshi's Story
.long 0x08
  #Singles Data
    .float -42,26.6
    .float 42,28
    .float 0,46.9
    .float 0,4.9
    .float -42,5
    .float 42,5
  #Teams Data
    .float -42,26.6
    .float -42,5
    .float -30,5
    .float 42,28
    .float 42,5
    .float 30,5
# Onett
.long 0x09
  #Singles Data
    .float -54,5
    .float 54,5
    .float -31.5,5
    .float 31.5,5
    .float -54,32
    .float 54,32
  #Teams Data
    .float -54,5
    .float -31.5,5
    .float -54,32
    .float 54,5
    .float 31.5,5
    .float 54,32
# Mute City
.long 0x0A
  # Singles Data
    .float -48,10
    .float 48,10
    .float -24,10
    .float 24,10
    .float -64,46
    .float 64,46
  #Teams Data
    .float -48,10
    .float -24,10
    .float -64,46
    .float 48,10
    .float 24,10
    .float 64,46
# Rainbow Cruise
.long 0x0B
  # Singles Data
    .float -45.98,10
    .float 46.42,10
    .float -15.62,10
    .float 14.74,10
    .float -15.62,40
    .float 14.74,40
  # Teams Data
    .float -45.98,10
    .float -15.62,10
    .float -15.62,40
    .float 46.42,10
    .float 14.74,10
    .float 14.74,40
# Jungle Japes
.long 0x0C
  # Singles Data
    .float -55,5
    .float 62.4,5
    .float -22.5,5
    .float 29.95,5
    .float -38.75,5
    .float 46.17,5
  # Teams Data
    .float -55,5
    .float -22.5,5
    .float -38.75,5
    .float 62.4,5
    .float 29.95,5
    .float 46.17,5
# Great Bay
.long 0x0D
  # Singles Data
    .float -91.8,20
    .float 85,57
    .float -53.67,20
    .float 0,20
    .float 48.33,32
    .float 85,37
  # Teams Data
    .float -91.8,20
    .float -61.9,20
    .float -32,20
    .float 85,57
    .float 48.33,32
    .float 85,37
# Yoshi's Island
.long 0x10
  # Singles Data
    .float -38.25,10
    .float 38.25,10
    .float -21.25,10
    .float 21.25,10
    .float -29.75,10
    .float 29.75,10
  # Teams Data
    .float -38.25,10
    .float -21.25,10
    .float -29.75,10
    .float 38.25,10
    .float 21.25,10
    .float 29.75,10
# Green Greens
.long 0x11
  # Singles Data
    .float -30,5
    .float 30,5
    .float -30,28
    .float 30,28
    .float -70,5
    .float 70,5
  # Teams Data
    .float -30,5
    .float -30,28
    .float -70,5
    .float 30,5
    .float 30,28
    .float 70,5
# Fourside
.long 0x12
  # Singles Data
    .float -70.5,5
    .float 41.25,5
    .float -45.25,5
    .float 16,5
    .float -57.87,5
    .float 28.62,5
  # Teams Data
    .float -70.5,5
    .float -45.25,5
    .float -57.87,5
    .float 41.25,5
    .float 16,5
    .float 28.62,5
# Mushroom Kingdom I
.long 0x13
  # Singles Data
    .float -30.6,10
    .float 30.6,10
    .float -12.75,10
    .float 12.75,10
    .float -69,10
    .float 69,10
  # Teams Data
    .float -30.6,10
    .float -12.75,10
    .float -69,10
    .float 30.6,10
    .float 12.75,10
    .float 69,10
# Mushroom Kingdom II
.long 0x14
  # Singles Data
    .float -43.4,10
    .float 43.4,10
    .float -22.4,10
    .float 22.4,10
    .float -64.4,10
    .float 64.4,10
  # Teams Data
    .float -43.4,10
    .float -22.4,10
    .float -64.4,10
    .float 43.4,10
    .float 22.4,10
    .float 64.4,10
# Venom
.long 0x16
  # Singles Data
    .float -43,28
    .float -58,-20
    .float -73,42
    .float 43,28
    .float 58,-20
    .float 73,42
  # Teams Data
    .float -43,28
    .float -58,-20
    .float -73,42
    .float 43,28
    .float 58,-20
    .float 73,42
# Flat Zone
.long 0x1B
  #Singles Data
    .float -61.6,-20
    .float 61.6,-20
    .float -31.6,-20
    .float 31.6,-20
    .float -31.6,40
    .float 31.6,40
  #Teams Data
    .float -61.6,-20
    .float -31.6,-20
    .float -31.6,40
    .float 61.6,-20
    .float 31.6,-20
    .float 31.6,40
# Dream Land
.long 0x1C
  #Singles Data
    .float -46.6,37.2
    .float 47.4,37.3
    .float 0,7
    .float 0,58.5
    .float -61.4,5
    .float 62.4,5
  #Teams Data
    .float -61.4,5
    .float -46.6,37.2
    .float -36.6,5
    .float 62.4,5
    .float 47.4,37.3
    .float 37.4,5
# Kongo Jungle 64
.long 0x1E
  # Singles Data
    .float -60,5
    .float 60,5
    .float -34,-7
    .float 34,-7
    .float -61,55
    .float 61,55
  # Teams Data
    .float -61,55
    .float -60,5
    .float -34,-7
    .float 61,55
    .float 60,5
    .float 34,-7
# Battlefield
.long 0x1F
  #Singles Data
    .float -38.8,35.2
    .float 38.8,35.2
    .float 0,8
    .float 0,62.4
    .float -58.8,5
    .float 58.8,5
  #Teams Data
    .float -38.8,35.2
    .float -38.8,5
    .float -58.8,5
    .float 38.8,35.2
    .float 38.8,5
    .float 58.8,5
# Final Destination
.long 0x20
  #Singles Data
    .float -60,10
    .float 60,10
    .float -20,10
    .float 20,10
    .float -40,10
    .float 40,10
  #Teams Data
    .float -60,10
    .float -20,10
    .float -40,10
    .float 60,10
    .float 20,10
    .float 40,10
# Terminator
.long -1
.align 2

NeutralSpawnTable_NotFound:
blrl
#Doubles
.long 0x00030102
.align 2
######################

Exit:
  restore
  lbz	r0, 0x24D0 (r31)
