# See LICENSE.md for license details

OUTPUT_ARCH(RISCV)

ENTRY(_entry)

SECTIONS
{
    . = 0x10000000;

    .text : {
        *(.text)
    }

    . = 0x10000200;

    .data : {
        *(.data)
    }
}
