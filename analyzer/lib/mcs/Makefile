NAME		:= libhanser

GCC_PATH	:= /usr/local/Cellar/gcc/5.3.0
CC_BIN		:= g++-5
CXX		:= $(GCC_PATH)/bin/$(CC_BIN)
CXXFLAGS	:= -Wall -fPIC -std=c++0x -O3 -DNDEBUG

SRC_DIR		:= cpp
OBJS_DIR	:= obj
LIB_DIR		:= lib

SOURCE_FILES	:= $(wildcard $(addsuffix /*.cpp, $(SRC_DIR)))
SOURCE_OBJECTS	:= $(patsubst $(SRC_DIR)/%, $(OBJS_DIR)/%, $(SOURCE_FILES:%.cpp=%.o))

SHARED		:= $(LIB_DIR)/$(NAME).so

.PHONY: all dirs clean

all:	$(SHARED)
$(SHARED): dirs $(SOURCE_OBJECTS)
	$(CXX) -shared $(SOURCE_OBJECTS) -o $(SHARED)

dirs:
	mkdir -p $(OBJS_DIR)
	mkdir -p $(LIB_DIR)

$(OBJS_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -rf $(OBJS_DIR)
	rm -rf $(LIB_DIR)
