.global _start
_start:
@CODE32
LDR r0, =thumbRoutine+1 @ enter Thumb state
BLX r0 @jump to Thumb code
@ continue here
.thumb
thumbRoutine:
ADD r1, #1
BX r14 @ return to ARM code and state
