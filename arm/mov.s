.global _start
_start:
mov r5,#10
mov r7, r5, lsl #2

examle3_3:
mov r0, #0
mov r1, #0x80000000
movs r0, r1, lsl #1
