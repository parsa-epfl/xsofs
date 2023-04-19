# See LICENSE.md for license details

OBJ_DIR  = build/obj-difftest.so
LIB      = build/difftest.so

DIR_C    = src/test/csrc/common
DIR_P    = src/test/csrc/plugin
DIR_D    = src/test/csrc/difftest

SRCS     = $(shell find $(DIR_C) -name "*.cpp") \
           $(shell find $(DIR_P) -name "*.cpp") \
           $(shell find $(DIR_D) -name "*.cpp")

OBJS     = $(SRCS:%.cpp=$(OBJ_DIR)/%.o)


CXXFLAGS = -g -O2 -fPIC -I$(DIR_C) -I$(DIR_P)/include -I$(DIR_D) -DNUM_CORES=$(HART) -std=c++11 -Wall
LDFLAGS  = -rdynamic -shared -Wl,--no-undefined -lpthread -ldl


all: $(LIB)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(LIB): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^
