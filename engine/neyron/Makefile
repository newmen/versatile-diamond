NAME		:= vd-neyron

ENGINE_DIR	:= ..
ENGINE_SRC_DIR	:= $(ENGINE_DIR)/cpp
ENGINE_OBJS_DIR	:= $(ENGINE_DIR)/obj

HANDG_DIR	:= ../hand-generations
HANDG_SRC_DIR	:= $(HANDG_DIR)/src
HANDG_OBJS_DIR	:= $(HANDG_DIR)/obj

ARKSFLAGS	:= -DNEYRON -DNDEBUG

GCC_PATH        := /usr
CXX             := $(GCC_PATH)/bin/g++
STANDART        := -std=c++11 $(ARKSFLAGS) -I$(ENGINE_SRC_DIR) -I$(HANDG_SRC_DIR)
LINKFLAGS	:= -lyaml-cpp

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

.PHONY: all dirs clean

all:    $(NAME)
$(NAME):        dirs $(MD_FILES) $(SOURCE_OBJECTS)
	$(MAKE) -C $(ENGINE_DIR) ARKSFLAGS="$(ARKSFLAGS)"
	$(MAKE) -C $(HANDG_DIR) simple-diamond ARKSFLAGS="$(ARKSFLAGS) -I$(HANDG_SRC_DIR) -I../neyron/$(SRC_DIR)"
	$(CXX) $(call find_objs, $(ENGINE_OBJS_DIR)) $(call find_objs, $(HANDG_OBJS_DIR)) $(call find_objs, $(OBJS_DIR)) -o $(NAME) $(LINKFLAGS)

dirs:
	mkdir -p $(OBJECTS_DIRS)

$(OBJS_DIR)/%.d: $(SRC_DIR)/%.cpp
	$(CXX) -c $(STANDART) -MM -MF $@ $<

$(OBJS_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) -c -O2 $(STANDART) -o $@ $<

clean:
	rm -f $(NAME)
	rm -rf $(OBJS_DIR)
	rm -rf $(HANDG_OBJS_DIR)
	rm -rf $(ENGINE_OBJS_DIR)

include $(wildcard $(addsuffix /*.d, $(OBJECTS_DIRS)))
