export HART ?= 2
export FPGA ?= 0
export CHK  ?= 1
export GEN  ?= gen

ifeq ($(FPGA),2)
export GEN  := $(GEN).fs
DUT         := $(GEN)/Dut.fs.sv
else
DUT         := $(GEN)/Dut.sv
endif

export JAVA_OPTS = -Xmx54G -XX:-UseGCOverheadLimit


PATCHES = $(notdir $(wildcard repo/patch/*.patch))


.PHONY: all $(DUT)

all:  $(PATCHES) $(DUT)

$(PATCHES):
	@cd repo/$(basename $@) && patch -p1 -N -s -r - < ../patch/$@ > /dev/null || exit 0

$(DUT):
	mkdir -p $(GEN) && mill xsofs.run
