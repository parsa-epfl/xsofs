# See LICENSE.md for license details

OBJ_DIR  = build/obj-firesim.so
LIB      = build/firesim.so
EXE      = build/firesim

DIR_M    = midas/src/main/cc
DIR_L    = firesim-lib/src/main/cc

OLD_SRCS = $(wildcard $(DIR_M)/bridges/*.cc)                \
           $(DIR_M)/simif.cc
NEW_SRCS = $(wildcard $(VERIF)/src/firesim/*.cpp)           \
           $(wildcard $(VERIF)/src/firesim/bridge/*.cpp)
EMU_SRCS = $(wildcard $(VERIF)/src/firesim/emu/*.cpp)
LIB_SRCS = $(wildcard $(FSDK_HOME)/fpga_libs/fpga_dma/*.c)  \
           $(wildcard $(FSDK_HOME)/fpga_libs/fpga_pci/*.c)  \
           $(wildcard $(FSDK_HOME)/fpga_libs/fpga_mgmt/*.c) \
           $(wildcard $(FSDK_HOME)/utils/*.c)

OLD_OBJS = $(OLD_SRCS:%.cc=$(OBJ_DIR)/%.o)
NEW_OBJS = $(NEW_SRCS:$(VERIF)/%.cpp=$(OBJ_DIR)/%.o)
EMU_OBJS = $(EMU_SRCS:$(VERIF)/%.cpp=$(OBJ_DIR)/%.o)
LIB_OBJS = $(LIB_SRCS:$(FSDK_HOME)/%.c=$(OBJ_DIR)/%.o)

INC_C    = $(FSDK_HOME)/include     \
           $(FSDK_HOME)/fpga_libs/fpga_mgmt

INC_CXX  = $(INC_C)                 \
           $(DIR_M)                 \
           $(DIR_M)/bridges         \
           $(DIR_L)                 \
           $(DIR_L)/bridges         \
           $(VERIF)/../${GEN}       \
           $(VERIF)/src             \
           $(VERIF)/src/firesim     \
           $(VERIF)/src/firesim/emu \
           $(VERIF)/src/firesim/bridge


CFLAGS   = -g -O2 -fPIC $(INC_C:%=-I%)   -std=gnu99 -Wall -Wno-parentheses -Wstrict-prototypes -Wmissing-prototypes
CXXFLAGS = -g -O2 -fPIC $(INC_CXX:%=-I%) -std=c++11 -Wall -Wno-unused-variable -include $(VERIF)/../${GEN}/Dut.fs.const.h -DREAL
LDFLAGS  = -Wl,--no-undefined -lpthread -lgmp


all: $(LIB) $(EXE)

$(OLD_OBJS): $(OBJ_DIR)/%.o: %.cc
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(NEW_OBJS): $(OBJ_DIR)/%.o: $(VERIF)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(EMU_OBJS): $(OBJ_DIR)/%.o: $(VERIF)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(LIB_OBJS): $(OBJ_DIR)/%.o: $(FSDK_HOME)/%.c
	@mkdir -p $(@D)
	$(CC)  $(CFLAGS)   -c -o $@ $<

$(OBJ_DIR)/new/mem.o: $(VERIF)/src/mem.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(LIB): $(OLD_OBJS) $(filter-out %/aws.o,$(NEW_OBJS)) $(EMU_OBJS) $(OBJ_DIR)/new/mem.o
	$(CXX) $(LDFLAGS) -rdynamic -shared -o $@ $^

$(EXE): $(OLD_OBJS) $(filter-out %/emu.o %/dut.o,$(NEW_OBJS)) $(LIB_OBJS) $(OBJ_DIR)/new/mem.o
	$(CXX) $(LDFLAGS) -o $@ $^
