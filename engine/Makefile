NAME		:= libengine

ARKSFLAGS	:= -DNDEBUG
STANDART	:= -std=c++11

GCC_PATH	:= /usr/local/Cellar/gcc/5.3.0
CC_BIN		:= g++-5
CXX		:= $(GCC_PATH)/bin/$(CC_BIN)
CFLAGS		:= $(STANDART) $(ARKSFLAGS) -O2 -I$(GCC_PATH)/include

SRC_DIR		:= cpp
OBJS_DIR	:= obj

SOURCE_DIRS	:= $(shell find $(SRC_DIR) -type d)
OBJECTS_DIRS	:= $(SOURCE_DIRS:$(SRC_DIR)%=$(OBJS_DIR)%)

SOURCE_FILES	:= $(wildcard $(addsuffix /*.cpp, $(SOURCE_DIRS)))
SOURCE_OBJECTS	:= $(patsubst $(SRC_DIR)/%, $(OBJS_DIR)/%, $(SOURCE_FILES:%.cpp=%.o))
MD_FILES	:= $(SOURCE_OBJECTS:%.o=%.d)

.PHONY: all dirs clean

all:	$(NAME)
$(NAME):	dirs $(MD_FILES) $(SOURCE_OBJECTS)

dirs:
	mkdir -p $(OBJECTS_DIRS)

$(OBJS_DIR)/%.d: $(SRC_DIR)/%.cpp
	$(CXX) -c $(STANDART) -MM -MF $@ $<

$(OBJS_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) -c $(CFLAGS) -o $@ $<

clean:
	rm -rf $(OBJS_DIR)

include $(wildcard $(addsuffix /*.d, $(OBJECTS_DIRS)))
