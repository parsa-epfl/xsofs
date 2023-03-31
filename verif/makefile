export VERIF = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export HART ?= 2
export FPGA ?= 0
export CHK  ?= 1
export GEN  ?= gen

export NEMU_HOME = $(VERIF)/../repo/nemu
export DIFF_HOME = $(VERIF)/../repo/difftest
export FSIM_HOME = $(VERIF)/../repo/firesim/sim

export FHDK_HOME = $(VERIF)/../repo/aws_fpga/hdk/common
export FSDK_HOME = $(VERIF)/../repo/aws_fpga/sdk/userspace
export FPGA_HOME = $(VERIF)/../fpga/src/firesim


SHELL   := /usr/bin/zsh
NULL    := >/dev/null 2>&1

TOOL    ?= verilator
TEST    ?= test
DBG     ?=

TSCALE  := 1ns/100ps

CMP_DIR ?= $(VERIF)/cmp
BIN_DIR ?= $(VERIF)/bin
RUN_DIR ?= $(VERIF)/run
FLIST   := $(VERIF)/flist/def.vc

ifneq ($(FPGA),0)
export GEN  := $(GEN).fs

CMP_DIR := $(CMP_DIR).fs
RUN_DIR := $(RUN_DIR).fs
endif

ifeq ($(FPGA),2)
FLIST   := $(VERIF)/flist/firesim.vc
endif

ifeq ($(FPGA),3)
TOOL    := vcs
FLIST   := $(VERIF)/flist/aws.vc
TSCALE  := 1ps/1ps
endif

ifeq ($(DBG),1)
GDB     := gdb -ex run --args
endif

INC_DIR := $(DIFF_HOME)/src/test/csrc/common            \
           $(DIFF_HOME)/src/test/csrc/plugin            \
           $(DIFF_HOME)/src/test/csrc/difftest          \
           $(FSIM_HOME)/midas/src/main/cc               \
           $(FSIM_HOME)/midas/src/main/cc/bridges       \
           $(FSIM_HOME)/firesim-lib/src/main/cc/bridges \
           $(VERIF)/../$(GEN)                           \
           $(VERIF)/src                                 \
           $(VERIF)/src/firesim                         \
           $(VERIF)/src/firesim/bridge

CMP_MT  ?= 14
RUN_MT  ?= 14

NEMU    := $(NEMU_HOME)/build/riscv64-nemu-interpreter-so
DIFF    := $(DIFF_HOME)/build/difftest.so
FSIM    := $(FSIM_HOME)/build/firesim.so

OBJCOPY := riscv64-linux-gnu-objcopy
ROM     := $(BIN_DIR)/src/rom/rom
ELF     := $(BIN_DIR)/$(TEST)
IMG     := $(BIN_DIR)/$(TEST).img
ROM_BIN := $(RUN_DIR)/rom
ELF_BIN := $(RUN_DIR)/bin

LOG     := $(RUN_DIR)/sim.log
DUMP    := $(RUN_DIR)/dump.log
FSDB    := $(RUN_DIR)/dump.fsdb

ifeq ($(CHK),1)
CMPARGS := +define+CHK +define+DIFFTEST -CFLAGS -DCHK -CFLAGS -DDIFFTEST
DPIARGS := -f $(VERIF)/flist/chk.vc
endif

RUNARGS := +lib=$(NEMU) +rom=$(ROM_BIN) +bin=$(ELF_BIN) +init=220

ifneq ($(wildcard $(IMG)),)
RUNARGS += +img=$(IMG)
else
RUNARGS += +img=
endif


.PHONY: all rtl sim cmp run dbg clean nemu diff $(NEMU) $(DIFF) $(FSIM) $(ROM)


all: rtl cmp run


rtl:
	make -C $(VERIF)/..

nemu: $(NEMU)
diff: $(DIFF)
fsim: $(FSIM)

$(NEMU):
ifeq ($(HART),1)
	make -C $(NEMU_HOME) riscv64-xs-ref_defconfig
else
	make -C $(NEMU_HOME) riscv64-dual-xs-ref_defconfig
endif
	make -C $(NEMU_HOME)

$(DIFF):
	make -C $(DIFF_HOME) -f $(VERIF)/difftest.mk

$(FSIM):
	make -C $(FSIM_HOME) -f $(VERIF)/firesim.mk

$(ROM):
	make -C $(BIN_DIR)/src/rom

$(ROM_BIN): $(ROM)
$(ELF_BIN): $(ELF)

$(ROM_BIN) $(ELF_BIN):
	mkdir -p $(RUN_DIR) && cd $(RUN_DIR) && $(OBJCOPY) -O binary $< $@

ifeq ($(FPGA),3)
sim:
	mkdir -p $(CMP_DIR) && cd $(CMP_DIR) && ln -sf $(FPGA_HOME)/sim/synopsys_sim.setup
else
sim:
endif

# not good
# https://github.com/chipsalliance/chisel3/pull/267

ifeq ($(FPGA),0)
cmp: $(NEMU) $(DIFF)
else
cmp: $(NEMU) $(DIFF) $(FSIM) sim
endif
ifeq ($(TOOL),verilator)
	mkdir -p $(CMP_DIR) && cd $(CMP_DIR) && rm -rf obj_dir && systemd-run --user --scope -p MemoryMax=40G -p MemoryHigh=40G verilator --cc --exe --assert --autoflush --trace --trace-underscore --x-initial-edge --no-timing --build -Wno-WIDTH -Wno-UNSIGNED -Wno-UNOPTTHREADS -O2 -j $(CMP_MT) --threads $(RUN_MT) --top-module tb --timescale $(TSCALE) -CFLAGS -std=c++11 $(INC_DIR:%=-CFLAGS -I%) -LDFLAGS -lsqlite3 $(CMPARGS) $(DPIARGS) -f $(FLIST) $(VERIF)/src/tb.cpp
else
	mkdir -p $(CMP_DIR) && cd $(CMP_DIR) && vlogan -full64 -sverilog -timescale=$(TSCALE) +define+DUMPFSDB $(CMPARGS) -f $(FLIST) && vcs -top TOP -top glbl -full64 -sverilog -j$(CMP_MT) -timescale=$(TSCALE) $(DPIARGS) -f $(FLIST).dpi +vcs+initreg+random -CFLAGS -std=c++11 $(INC_DIR:%=-CFLAGS -I%) -LDFLAGS -lsqlite3 -LDFLAGS -rdynamic -LDFLAGS -Wl,--no-as-needed -debug_pp -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a
endif

run: $(ROM_BIN) $(ELF_BIN)
ifeq ($(TOOL),verilator)
	cd $(RUN_DIR) && $(GDB) $(CMP_DIR)/obj_dir/Vtb $(RUNARGS) 2>$(LOG)
else
	cd $(RUN_DIR) && $(GDB) $(CMP_DIR)/simv +vcs+initreg+0 -l $(LOG) $(RUNARGS)
endif

dbg:
	cd $(RUN_DIR) && verdi -nologo -sv -ssv -ssy -f $(FLIST) -ssf $(FSDB) $(NULL) &!

clean:
	rm -rf $(CMP_DIR) $(RUN_DIR)
