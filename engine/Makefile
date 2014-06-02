NAME		:= engine

ARKSFLAGS	:= -DNDEBUG -DTHREADS_NUM=1
ICC_PATH	:= /opt/intel/composerxe

CXX		:= $(ICC_PATH)/bin/icpc
CXXFLAGS	:= -std=c++11 -openmp -O2 -falign-functions=16 -ansi-alias -fstrict-aliasing -w1 -Wcheck -wd654,1572,411,873,1125,2259 $(ARKSFLAGS)

SRC_DIR		:= cpp
OBJS_DIR	:= obj

OBJECTS_DIRS	:= \
	$(OBJS_DIR)/ \
	$(OBJS_DIR)/atoms/ \
	$(OBJS_DIR)/mc/ \
	$(OBJS_DIR)/phases/ \
	$(OBJS_DIR)/reactions/ \
	$(OBJS_DIR)/species/ \
	$(OBJS_DIR)/tools/ \
	$(OBJS_DIR)/tools/savers/

HEADER_FILES	:= \
	$(SRC_DIR)/atoms/atom.h \
	$(SRC_DIR)/atoms/lattice.h \
	$(SRC_DIR)/atoms/neighbours.h \
	$(SRC_DIR)/mc/base_events_container.h \
	$(SRC_DIR)/mc/common_mc_data.h \
	$(SRC_DIR)/mc/counter.h \
	$(SRC_DIR)/mc/events_container.h \
	$(SRC_DIR)/mc/mc.h \
	$(SRC_DIR)/mc/multi_events_container.h \
	$(SRC_DIR)/mc/random_generator.h \
	$(SRC_DIR)/phases/amorph.h \
	$(SRC_DIR)/phases/crystal.h \
	$(SRC_DIR)/phases/crystal_atoms_iterator.h \
	$(SRC_DIR)/reactions/concrete_lateral_reaction.h \
	$(SRC_DIR)/reactions/concrete_typical_reaction.h \
	$(SRC_DIR)/reactions/lateral_reaction.h \
	$(SRC_DIR)/reactions/reaction.h \
	$(SRC_DIR)/reactions/spec_reaction.h \
	$(SRC_DIR)/reactions/targets.h \
	$(SRC_DIR)/reactions/typical_reaction.h \
	$(SRC_DIR)/reactions/ubiquitous_reaction.h \
	$(SRC_DIR)/species/additional_atoms_wrapper.h \
	$(SRC_DIR)/species/atom_shift_wrapper.h \
	$(SRC_DIR)/species/atoms_swap_wrapper.h \
	$(SRC_DIR)/species/base_spec.h \
	$(SRC_DIR)/species/dependent_spec.h \
	$(SRC_DIR)/species/empty_spec.h \
	$(SRC_DIR)/species/keeper.h \
	$(SRC_DIR)/species/lateral_spec.h \
	$(SRC_DIR)/species/localable_role.h \
	$(SRC_DIR)/species/parent_spec.h \
	$(SRC_DIR)/species/reactant.h \
	$(SRC_DIR)/species/sealer.h \
	$(SRC_DIR)/species/source_spec.h \
	$(SRC_DIR)/species/specific_spec.h \
	$(SRC_DIR)/tools/collector.h \
	$(SRC_DIR)/tools/common.h \
	$(SRC_DIR)/tools/creator.h \
	$(SRC_DIR)/tools/debug_print.h \
	$(SRC_DIR)/tools/error.h \
	$(SRC_DIR)/tools/factory.h \
	$(SRC_DIR)/tools/lockable.h \
	$(SRC_DIR)/tools/process_mem_usage.h \
	$(SRC_DIR)/tools/runner.h \
	$(SRC_DIR)/tools/savers/atom_info.h \
	$(SRC_DIR)/tools/savers/bond_info.h \
	$(SRC_DIR)/tools/savers/crystal_slice_saver.h \
	$(SRC_DIR)/tools/savers/mol_accumulator.h \
	$(SRC_DIR)/tools/savers/mol_saver.h \
	$(SRC_DIR)/tools/savers/sdf_saver.h \
	$(SRC_DIR)/tools/savers/volume_saver_factory.h \
	$(SRC_DIR)/tools/scavenger.h \
	$(SRC_DIR)/tools/typed.h \
	$(SRC_DIR)/tools/vector3d.h \
	$(SRC_DIR)/tools/yaml_config_reader.h

SOURCE_FILES	:= \
	$(SRC_DIR)/atoms/atom.cpp \
	$(SRC_DIR)/atoms/lattice.cpp \
	$(SRC_DIR)/mc/base_events_container.cpp \
	$(SRC_DIR)/mc/common_mc_data.cpp \
	$(SRC_DIR)/mc/counter.cpp \
	$(SRC_DIR)/mc/events_container.cpp \
	$(SRC_DIR)/mc/multi_events_container.cpp \
	$(SRC_DIR)/mc/random_generator.cpp \
	$(SRC_DIR)/phases/amorph.cpp \
	$(SRC_DIR)/phases/crystal.cpp \
	$(SRC_DIR)/reactions/lateral_reaction.cpp \
	$(SRC_DIR)/reactions/ubiquitous_reaction.cpp \
	$(SRC_DIR)/species/base_spec.cpp \
	$(SRC_DIR)/species/empty_spec.cpp \
	$(SRC_DIR)/species/lateral_spec.cpp \
	$(SRC_DIR)/species/parent_spec.cpp \
	$(SRC_DIR)/species/specific_spec.cpp \
	$(SRC_DIR)/tools/common.cpp \
	$(SRC_DIR)/tools/lockable.cpp \
	$(SRC_DIR)/tools/process_mem_usage.cpp \
	$(SRC_DIR)/tools/runner.cpp \
	$(SRC_DIR)/tools/savers/atom_info.cpp \
	$(SRC_DIR)/tools/savers/bond_info.cpp \
	$(SRC_DIR)/tools/savers/crystal_slice_saver.cpp \
	$(SRC_DIR)/tools/savers/mol_accumulator.cpp \
	$(SRC_DIR)/tools/savers/mol_saver.cpp \
	$(SRC_DIR)/tools/savers/sdf_saver.cpp \
	$(SRC_DIR)/tools/savers/volume_saver_factory.cpp \
	$(SRC_DIR)/tools/scavenger.cpp \
	$(SRC_DIR)/tools/yaml_config_reader.cpp

SOURCE_OBJECTS	:= $(SOURCE_FILES:%.cpp=%.o)

###################

define compilate_obj
	$(CXX) $(CXXFLAGS) -o $(patsubst $(SRC_DIR)/%, $(OBJS_DIR)/%, $(1)) -c $(2)
endef

###################

.PHONY: all dirs clean

all:	$(NAME)
$(NAME):	dirs $(SOURCE_OBJECTS)

dirs:
	mkdir -p $(OBJECTS_DIRS)

.h.o:
	$(call compilate_obj, $@, $<)

.cpp.o:	$(HEADER_FILES)
	$(call compilate_obj, $@, $<)

clean:
	rm -rf $(OBJS_DIR)
