CC      = riscv64-linux-gnu-gcc
AS      = riscv64-linux-gnu-as
LD      = riscv64-linux-gnu-ld
OBJCOPY = riscv64-linux-gnu-objcopy

ASFLAGS =
LDFLAGS =


.PHONY: clean


all: rom

dtb: ../util/dts
	dtc -O dtb -o $@ $<

rom: rom.o
	$(LD) $(LDFLAGS) -o $@ -T ../util/link.ld $<

clean:
	rm -rf *.o rom dtb
