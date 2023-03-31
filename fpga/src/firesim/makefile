export FSIM  = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export SRC  ?= $(FSIM)/../../../src
export GEN  ?= $(FSIM)/../../../gen.fs
export HDK  ?= $(FSIM)/../../../repo/aws_fpga/hdk/common/shell_stable

# AreaOptimized_high/medium
# AlternateRoutability
export DIR_SYNTH ?= AreaOptimized_high
# AltSpreadLogic_high/medium/low
export DIR_PLACE ?= AltSpreadLogic_low
# AlternateCLBRouting
export DIR_ROUTE ?= Default
# any
export PBLOCK    ?= yes


TOP_DIR := $(FSIM)/top.$(DIR_SYNTH)
DCP_DIR := $(FSIM)/dcp.$(DIR_SYNTH).$(PBLOCK).$(DIR_PLACE).$(DIR_ROUTE)
SIM_DIR := $(FSIM)/sim

DUT     := Dut.fs.sv
TOP     := $(TOP_DIR)/CL.dcp
DCP     := $(DCP_DIR)/SH_CL.dcp
TAR     := $(DCP_DIR)/SH_CL.tar


.PHONY: all rtl top dcp sim tar clean


all: rtl top dcp


rtl:
	export GEN=gen && make -C $(FSIM)/../../.. FPGA=2 CHK=0

top:
	@mkdir -p $(TOP_DIR) && cd $(TOP_DIR) && exec vivado -mode batch -source ../top.tcl -tclargs $(GEN)/$(DUT) $(TOP)

dcp:
	@mkdir -p $(DCP_DIR) && cd $(DCP_DIR) && exec vivado -mode batch -source ../dcp.tcl -tclargs $(TOP)        $(DCP)

sim:
	@mkdir -p $(SIM_DIR) && cd $(SIM_DIR) && exec vivado -mode batch -source ../sim.tcl

tar:
	@mkdir -p $(DCP_DIR) && cd $(DCP_DIR) && exec ../tar.sh $(notdir $(DCP)) $(TAR)

clean:
	rm -rf $(TOP_DIR) $(DCP_DIR)
