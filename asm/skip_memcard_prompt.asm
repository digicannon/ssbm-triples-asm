################################################################################
# Address: 801af6f4
# https://github.com/project-slippi/slippi-ssbm-asm/blob/07c581d0d177b3da2b90ee89aba30e36c39003d1/External/Skip%20Memcard%20Prompt/Skip%20Memcard%20Prompt.asm
################################################################################
.include "common.s"

.set MEMCARD_NONE,0xF
.set MEMCARD_NONE2,0xD

#Check if no memcard inserted
  cmpwi r29,MEMCARD_NONE
  beq NoMemcard
  cmpwi r29,MEMCARD_NONE2
  beq NoMemcard
  b Original

NoMemcard:
#Exit memcard think and disable saving
  branch r12,0x801b01ac

Original:
  cmpwi r29,0
