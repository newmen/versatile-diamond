NAME		:= simple-diamond

ENGINE_DIR	:= ..
ENGINE_SRC_DIR	:= $(ENGINE_DIR)/cpp
ENGINE_OBJS_DIR	:= $(ENGINE_DIR)/obj
ENGINE_OBJECT_DIRS := $(shell find $(ENGINE_OBJS_DIR) -type d)
ENGINE_OBJECTS	:= $(wildcard $(addsuffix /*.o, $(ENGINE_OBJECT_DIRS)))

ARKSFLAGS	:= -DNDEBUG
STANDART	:= -std=c++11

GCC_PATH	:= /usr
CXX		:= $(GCC_PATH)/bin/g++
DFLAGS		:= $(STANDART) -I$(ENGINE_SRC_DIR)
CFLAGS		:= $(DFLAGS) -O2
LFLAGS		:= $(STANDART) -lyaml-cpp

HGEN_SRC_DIR	:= src
HGEN_OBJS_DIR	:= obj

SOURCE_DIRS     := $(shell find $(HGEN_SRC_DIR) -type d)
OBJECTS_DIRS    := $(SOURCE_DIRS:$(HGEN_SRC_DIR)%=$(HGEN_OBJS_DIR)%)

SOURCE_FILES    := $(wildcard $(addsuffix /*.cpp, $(SOURCE_DIRS)))
SOURCE_OBJECTS  := $(patsubst $(HGEN_SRC_DIR)/%, $(HGEN_OBJS_DIR)/%, $(SOURCE_FILES:%.cpp=%.o))
MD_FILES        := $(SOURCE_OBJECTS:%.o=%.d)

.PHONY: all dirs exec clean

all:	exec
$(NAME):	dirs $(MD_FILES) $(SOURCE_OBJECTS)

exec: $(NAME)
	$(CXX) $(LFLAGS) $(ENGINE_OBJECTS) $(SOURCE_OBJECTS) -o $^

dirs:
	mkdir -p $(OBJECTS_DIRS)

$(HGEN_OBJS_DIR)/%.d: $(HGEN_SRC_DIR)/%.cpp
	$(CXX) -c $(DFLAGS) -M -MF $@ $<

$(HGEN_OBJS_DIR)/%.o: $(HGEN_SRC_DIR)/%.cpp
	$(CXX) -c $(CFLAGS) -o $@ $<

clean:
	rm -rf $(HGEN_OBJS_DIR)
	rm -f $(NAME)

include $(wildcard $(addsuffix /*.d, $(OBJECTS_DIRS)))
