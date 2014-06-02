NAME		:= simple-diamond

ENGINE_DIR	:= ../../engine
ENGINE_SRC_DIR	:= $(ENGINE_DIR)/cpp
ENGINE_OBJS_DIR	:= $(ENGINE_DIR)/obj
ENGINE_OBJECT_DIRS := $(shell find $(ENGINE_OBJS_DIR) -type d)
ENGINE_OBJECTS	:= $(wildcard $(addsuffix /*.o, $(ENGINE_OBJECT_DIRS)))

ARKSFLAGS	:= -DNDEBUG -DTHREADS_NUM=1 -I$(ENGINE_SRC_DIR)
ICC_PATH	:= /opt/intel/composerxe

CXX		:= $(ICC_PATH)/bin/icpc
CXXFLAGS	:= -std=c++11 -openmp -O2 -falign-functions=16 -ansi-alias -fstrict-aliasing -w1 -Wcheck -wd654,1572,411,873,1125,2259 $(ARKSFLAGS)
LINKFLAGS	:= -std=c++11 -L$(ICC_PATH)/lib/intel64/ -liomp5 -openmp -lyaml-cpp

HGEN_SRC_DIR	:= .
HGEN_OBJS_DIR	:= obj

OBJECTS_DIRS	:= \
	$(HGEN_OBJS_DIR)/ \
	$(HGEN_OBJS_DIR)/atoms/ \
	$(HGEN_OBJS_DIR)/builders/ \
	$(HGEN_OBJS_DIR)/phases/ \
	$(HGEN_OBJS_DIR)/reactions/ \
	$(HGEN_OBJS_DIR)/reactions/lateral/ \
	$(HGEN_OBJS_DIR)/reactions/typical/ \
	$(HGEN_OBJS_DIR)/reactions/typical/lookers/ \
	$(HGEN_OBJS_DIR)/reactions/ubiquitous/ \
	$(HGEN_OBJS_DIR)/reactions/ubiquitous/data/ \
	$(HGEN_OBJS_DIR)/reactions/ubiquitous/local/ \
	$(HGEN_OBJS_DIR)/species/ \
	$(HGEN_OBJS_DIR)/species/base/ \
	$(HGEN_OBJS_DIR)/species/empty/ \
	$(HGEN_OBJS_DIR)/species/sidepiece/ \
	$(HGEN_OBJS_DIR)/species/specific/

HEADER_FILES	:= \
	$(HGEN_SRC_DIR)/atoms/c.h \
	$(HGEN_SRC_DIR)/atoms/specified_atom.h \
	$(HGEN_SRC_DIR)/builders/atom_builder.h \
	$(HGEN_SRC_DIR)/env.h \
	$(HGEN_SRC_DIR)/finder.h \
	$(HGEN_SRC_DIR)/handbook.h \
	$(HGEN_SRC_DIR)/names.h \
	$(HGEN_SRC_DIR)/phases/diamond.h \
	$(HGEN_SRC_DIR)/phases/diamond_atoms_iterator.h \
	$(HGEN_SRC_DIR)/phases/diamond_relations.h \
	$(HGEN_SRC_DIR)/phases/phase_boundary.h \
	$(HGEN_SRC_DIR)/reactions/concretizable_role.h \
	$(HGEN_SRC_DIR)/reactions/laterable_role.h \
	$(HGEN_SRC_DIR)/reactions/lateral.h \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_drop_at_end.h \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_drop_in_middle.h \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_formation_at_end.h \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_formation_in_middle.h \
	$(HGEN_SRC_DIR)/reactions/local.h \
	$(HGEN_SRC_DIR)/reactions/rates_reader.h \
	$(HGEN_SRC_DIR)/reactions/registrator.h \
	$(HGEN_SRC_DIR)/reactions/typical.h \
	$(HGEN_SRC_DIR)/reactions/typical/abs_hydrogen_from_gap.h \
	$(HGEN_SRC_DIR)/reactions/typical/ads_methyl_to_111.h \
	$(HGEN_SRC_DIR)/reactions/typical/ads_methyl_to_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/des_methyl_from_111.h \
	$(HGEN_SRC_DIR)/reactions/typical/des_methyl_from_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/des_methyl_from_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_drop.h \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_drop_near_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_formation.h \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_formation_near_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/form_two_bond.h \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_stand_to_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_stand_to_one_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_to_methyl.h \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_to_two_bridges.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_activated_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_gap.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_high_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_methyl_on_111.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_methyl_on_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_methyl_on_bridge_cbi.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_methyl_on_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/lookers/near_part_of_gap.h \
	$(HGEN_SRC_DIR)/reactions/typical/methyl_on_dimer_hydrogen_migration.h \
	$(HGEN_SRC_DIR)/reactions/typical/methyl_to_high_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer_from_111.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer_from_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer_from_high_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap_from_111.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap_from_dimer.h \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap_from_high_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/next_level_bridge_to_high_bridge.h \
	$(HGEN_SRC_DIR)/reactions/typical/two_bridges_to_high_bridge.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/data/activation_data.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/data/deactivation_data.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/local/methyl_on_dimer_activation.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/local/methyl_on_dimer_deactivation.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/surface_activation.h \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/surface_deactivation.h \
	$(HGEN_SRC_DIR)/run.h \
	$(HGEN_SRC_DIR)/species/base.h \
	$(HGEN_SRC_DIR)/species/base/bridge.h \
	$(HGEN_SRC_DIR)/species/base/bridge_cri.h \
	$(HGEN_SRC_DIR)/species/base/bridge_with_dimer.h \
	$(HGEN_SRC_DIR)/species/base/methyl_on_bridge.h \
	$(HGEN_SRC_DIR)/species/base/methyl_on_dimer.h \
	$(HGEN_SRC_DIR)/species/base/two_bridges.h \
	$(HGEN_SRC_DIR)/species/empty.h \
	$(HGEN_SRC_DIR)/species/empty/shifted_dimer.h \
	$(HGEN_SRC_DIR)/species/empty/swapped_bridge.h \
	$(HGEN_SRC_DIR)/species/overall.h \
	$(HGEN_SRC_DIR)/species/sidepiece.h \
	$(HGEN_SRC_DIR)/species/sidepiece/dimer.h \
	$(HGEN_SRC_DIR)/species/specific.h \
	$(HGEN_SRC_DIR)/species/specific/bridge_crh.h \
	$(HGEN_SRC_DIR)/species/specific/bridge_crs.h \
	$(HGEN_SRC_DIR)/species/specific/bridge_crs_cti_cli.h \
	$(HGEN_SRC_DIR)/species/specific/bridge_ctsi.h \
	$(HGEN_SRC_DIR)/species/specific/bridge_with_dimer_cbti_cbrs_cdli.h \
	$(HGEN_SRC_DIR)/species/specific/bridge_with_dimer_cdli.h \
	$(HGEN_SRC_DIR)/species/specific/dimer_cri_cli.h \
	$(HGEN_SRC_DIR)/species/specific/dimer_crs.h \
	$(HGEN_SRC_DIR)/species/specific/dimer_crs_cli.h \
	$(HGEN_SRC_DIR)/species/specific/high_bridge.h \
	$(HGEN_SRC_DIR)/species/specific/high_bridge_cms.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_111_cmiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_111_cmsiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_111_cmssiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbi_cmiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbi_cmsiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbi_cmssiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbs_cmsiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cls_cmhiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cmiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cmsiu.h \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cmssiu.h \
	$(HGEN_SRC_DIR)/species/specific/two_bridges_ctri_cbrs.h

SOURCE_FILES	:= \
	$(HGEN_SRC_DIR)/atoms/c.cpp \
	$(HGEN_SRC_DIR)/env.cpp \
	$(HGEN_SRC_DIR)/finder.cpp \
	$(HGEN_SRC_DIR)/handbook.cpp \
	$(HGEN_SRC_DIR)/phases/diamond.cpp \
	$(HGEN_SRC_DIR)/phases/phase_boundary.cpp \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_drop_at_end.cpp \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_drop_in_middle.cpp \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_formation_at_end.cpp \
	$(HGEN_SRC_DIR)/reactions/lateral/dimer_formation_in_middle.cpp \
	$(HGEN_SRC_DIR)/reactions/rates_reader.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/abs_hydrogen_from_gap.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/ads_methyl_to_111.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/ads_methyl_to_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/des_methyl_from_111.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/des_methyl_from_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/des_methyl_from_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_drop.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_drop_near_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_formation.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/dimer_formation_near_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/form_two_bond.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_stand_to_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_stand_to_one_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_to_methyl.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/high_bridge_to_two_bridges.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/methyl_on_dimer_hydrogen_migration.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/methyl_to_high_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer_from_111.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer_from_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_at_dimer_from_high_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap_from_111.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap_from_dimer.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/migration_down_in_gap_from_high_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/next_level_bridge_to_high_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/typical/two_bridges_to_high_bridge.cpp \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/local/methyl_on_dimer_activation.cpp \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/local/methyl_on_dimer_deactivation.cpp \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/surface_activation.cpp \
	$(HGEN_SRC_DIR)/reactions/ubiquitous/surface_deactivation.cpp \
	$(HGEN_SRC_DIR)/run.cpp \
	$(HGEN_SRC_DIR)/species/base/bridge.cpp \
	$(HGEN_SRC_DIR)/species/base/bridge_cri.cpp \
	$(HGEN_SRC_DIR)/species/base/bridge_with_dimer.cpp \
	$(HGEN_SRC_DIR)/species/base/methyl_on_bridge.cpp \
	$(HGEN_SRC_DIR)/species/base/methyl_on_dimer.cpp \
	$(HGEN_SRC_DIR)/species/base/two_bridges.cpp \
	$(HGEN_SRC_DIR)/species/empty/shifted_dimer.cpp \
	$(HGEN_SRC_DIR)/species/empty/swapped_bridge.cpp \
	$(HGEN_SRC_DIR)/species/sidepiece/dimer.cpp \
	$(HGEN_SRC_DIR)/species/specific/bridge_crh.cpp \
	$(HGEN_SRC_DIR)/species/specific/bridge_crs.cpp \
	$(HGEN_SRC_DIR)/species/specific/bridge_crs_cti_cli.cpp \
	$(HGEN_SRC_DIR)/species/specific/bridge_ctsi.cpp \
	$(HGEN_SRC_DIR)/species/specific/bridge_with_dimer_cbti_cbrs_cdli.cpp \
	$(HGEN_SRC_DIR)/species/specific/bridge_with_dimer_cdli.cpp \
	$(HGEN_SRC_DIR)/species/specific/dimer_cri_cli.cpp \
	$(HGEN_SRC_DIR)/species/specific/dimer_crs.cpp \
	$(HGEN_SRC_DIR)/species/specific/dimer_crs_cli.cpp \
	$(HGEN_SRC_DIR)/species/specific/high_bridge.cpp \
	$(HGEN_SRC_DIR)/species/specific/high_bridge_cms.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_111_cmiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_111_cmsiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_111_cmssiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbi_cmiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbi_cmsiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbi_cmssiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_bridge_cbs_cmsiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cls_cmhiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cmiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cmsiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/methyl_on_dimer_cmssiu.cpp \
	$(HGEN_SRC_DIR)/species/specific/two_bridges_ctri_cbrs.cpp \
	$(HGEN_SRC_DIR)/main.cpp

SOURCE_OBJECTS	:= $(SOURCE_FILES:%.cpp=%.o)
HGEN_OBJECTS	:= $(patsubst $(HGEN_SRC_DIR)/%, $(HGEN_OBJS_DIR)/%, $(SOURCE_OBJECTS))

###################

.PHONY: all dirs files exec clean

all:	$(NAME)
$(NAME):	dirs files exec

dirs:
	mkdir -p $(OBJECTS_DIRS)

files:	$(SOURCE_OBJECTS)

exec:
	$(CXX) $(LINKFLAGS) $(ENGINE_OBJECTS) $(HGEN_OBJECTS) -o $(NAME)

.cpp.o:
	$(CXX) $(CXXFLAGS) -o $(addprefix $(HGEN_OBJS_DIR)/, $@) -c $<

clean:
	rm -rf $(HGEN_OBJS_DIR)
