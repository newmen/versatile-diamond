ARKSFLAGS	:= -DPARALLEL -DTHREADS_NUM=2
ICC_PATH	:= /opt/intel/composerxe

CXX		:= $(ICC_PATH)/bin/icpc
CXXFLAGS	:= -DNDEBUG -std=c++11 -openmp -O2 -falign-functions=16 -ansi-alias -fstrict-aliasing -w1 -Wcheck -wd654,1572,411,873,1125,2259 $(ARKSFLAGS)
LINKFLAGS	:= -std=c++11 -L$(ICC_PATH)/lib/intel64/ -liomp5 -openmp

NAME	:= engine

SOURCE_SUBDIRS	:= tools tools/saver generations generations/builders generations/species generations/species/base generations/species/specific generations/species/sidepiece generations/atoms generations/phases generations/reactions generations/reactions/lateral generations/reactions/ubiquitous generations/reactions/ubiquitous/local generations/reactions/ubiquitous/data generations/reactions/typical generations/reactions/typical/lookers species atoms phases mc reactions

SRC_DIR := cpp
OBJ_DIR := obj

SOURCE_DIRS		:= $(addprefix $(SRC_DIR)/, $(SOURCE_SUBDIRS))
OBJECTS_DIRS		:= $(addprefix $(OBJ_DIR)/, $(SOURCE_SUBDIRS))

SOURCE_FILES		:= $(wildcard $(addsuffix /*.cpp, $(SOURCE_DIRS))) $(SRC_DIR)/main.cpp
SOURCE_OBJECTS		:= $(SOURCE_FILES:%.cpp=%.o)
REAL_OBJECTS		:= $(patsubst $(SRC_DIR)/%, $(OBJ_DIR)/%, $(SOURCE_OBJECTS))

all:	$(NAME)
$(NAME): dirs files exec

exec:
	$(CXX) $(LINKFLAGS) $(REAL_OBJECTS) -o $(NAME)

dirs:
	mkdir -p $(OBJECTS_DIRS)

files: $(SOURCE_OBJECTS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -o $(patsubst $(SRC_DIR)/%, $(OBJ_DIR)/%, $@) -c $<

clean:
	rm -rf obj
