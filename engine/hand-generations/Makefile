NAME		:= simple-diamond

ENGINE_DIR	:= ..
ENGINE_SRC_DIR	:= $(ENGINE_DIR)/cpp
ENGINE_OBJS_DIR	:= $(ENGINE_DIR)/obj
ENGINE_OBJECT_DIRS := $(shell find $(ENGINE_OBJS_DIR) -type d)
ENGINE_OBJECTS	:= $(wildcard $(addsuffix /*.o, $(ENGINE_OBJECT_DIRS)))

ARKSFLAGS	:= -DNDEBUG -DTHREADS_NUM=1
ARKSWINC	:= $(ARKSFLAGS) -I$(ENGINE_SRC_DIR)

GCC_PATH	:= /usr
CXX		:= $(GCC_PATH)/bin/g++
STANDART	:= -std=c++11 $(ARKSWINC)

ICC_PATH	:= /opt/intel/composerxe
ICPC		:= $(ICC_PATH)/bin/icpc
ICPCFLAGS	:= $(STANDART) -openmp -O2 -falign-functions=16 -ansi-alias -fstrict-aliasing -w1 -Wcheck -wd654,1572,411,873,1125,2259
LINKFLAGS	:= -std=c++11 -L$(ICC_PATH)/lib/intel64 -liomp5 -openmp -lyaml-cpp

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
	$(ICPC) $(LINKFLAGS) $(ENGINE_OBJECTS) $(SOURCE_OBJECTS) -o $^

dirs:
	mkdir -p $(OBJECTS_DIRS)

$(HGEN_OBJS_DIR)/%.d: $(HGEN_SRC_DIR)/%.cpp
	$(CXX) -c $(STANDART) -M -MF $@ $<

$(HGEN_OBJS_DIR)/%.o: $(HGEN_SRC_DIR)/%.cpp
	$(ICPC) -c $(ICPCFLAGS) -o $@ $<

clean:
	rm -rf $(HGEN_OBJS_DIR)
	rm -f $(NAME)

include $(wildcard $(addsuffix /*.d, $(OBJECTS_DIRS)))
