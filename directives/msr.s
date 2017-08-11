.global _start
_start:
mrs r1,cpsr
bic r1, r1, #0x80
msr cpsr_c, r1
