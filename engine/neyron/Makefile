NAME		:= vd-neyron

ENGINE_DIR	:= ..
ENGINE_SRC_DIR	:= $(ENGINE_DIR)/cpp
ENGINE_OBJS_DIR	:= $(ENGINE_DIR)/obj

HANDG_DIR	:= ../hand-generations
HANDG_SRC_DIR	:= $(HANDG_DIR)/src
HANDG_OBJS_DIR	:= $(HANDG_DIR)/obj

ARKSFLAGS	:= -DNOUT -DNEYRON -DNDEBUG

GCC_PATH        := /usr
CXX             := $(GCC_PATH)/bin/g++
STANDART        := -std=c++11 $(ARKSFLAGS) -I$(ENGINE_SRC_DIR) -I$(HANDG_SRC_DIR)

ICC_PATH        := /opt/intel/composerxe
ICPC            := $(ICC_PATH)/bin/icpc
ICPCFLAGS       := $(STANDART) -openmp -O2 -falign-functions=16 -ansi-alias -fstrict-aliasing -w1 -Wcheck -wd654,1572,411,873,1125,2259

SRC_DIR         := src
OBJS_DIR        := obj

SOURCE_DIRS     := $(shell find $(SRC_DIR) -type d)
OBJECTS_DIRS    := $(SOURCE_DIRS:$(SRC_DIR)%=$(OBJS_DIR)%)

SOURCE_FILES    := $(wildcard $(addsuffix /*.cpp, $(SOURCE_DIRS)))
SOURCE_OBJECTS  := $(patsubst $(SRC_DIR)/%, $(OBJS_DIR)/%, $(SOURCE_FILES:%.cpp=%.o))
MD_FILES        := $(SOURCE_OBJECTS:%.o=%.d)

define find_objs
	$(shell find $(1) -name *.o -type f)
endef

LINKFLAGS	:= $(ICPCFLAGS) -lyaml-cpp

.PHONY: all dirs clean

all:    $(NAME)
$(NAME):        dirs $(MD_FILES) $(SOURCE_OBJECTS)
	$(MAKE) -C $(ENGINE_DIR) ARKSFLAGS="$(ARKSFLAGS)"
	$(MAKE) -C $(HANDG_DIR) simple-diamond ARKSFLAGS="$(ARKSFLAGS) -I$(HANDG_SRC_DIR) -I../neyron/$(SRC_DIR)"
	$(ICPC) $(LINKFLAGS) $(call find_objs, $(ENGINE_OBJS_DIR)) $(call find_objs, $(HANDG_OBJS_DIR)) $(call find_objs, $(OBJS_DIR)) -o $(NAME)

dirs:
	mkdir -p $(OBJECTS_DIRS)

$(OBJS_DIR)/%.d: $(SRC_DIR)/%.cpp
	$(CXX) -c $(STANDART) -MM -MF $@ $<

$(OBJS_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(ICPC) -c $(ICPCFLAGS) -o $@ $<

clean:
	rm -f $(NAME)
	$(MAKE) -C $(ENGINE_DIR) clean
	$(MAKE) -C $(HANDG_DIR) clean

include $(wildcard $(addsuffix /*.d, $(OBJECTS_DIRS)))
