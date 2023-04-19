# See LICENSE.md for license details

.global _entry

.section .text
_entry:
        csrr    a0, mhartid
        la      a1, dtb
        la      t0, mem
        ld      t0, 0(t0)
        jr      t0

.balign 8
mem:
.dword  0x80000000

.section .data
dtb:
.incbin  "dtb"
