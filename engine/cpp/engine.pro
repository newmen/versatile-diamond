TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

#QMAKE_CXXFLAGS += -D_GLIBCXX_DEBUG_PEDANTIC
QMAKE_CXXFLAGS += -DDEBUG
#QMAKE_CXXFLAGS += -DPRINT

QMAKE_CXXFLAGS += -std=c++0x
QMAKE_CXXFLAGS += -DTHREADS_NUM=1
#QMAKE_CXXFLAGS += -fopenmp -DPARALLEL -DTHREADS_NUM=3
#LIBS += -fopenmp -lstdc++

#QMAKE_CXXFLAGS += -std=c++11
#QMAKE_CXXFLAGS += -DTHREADS_NUM=1
##QMAKE_CXXFLAGS += -openmp -DPARALLEL -DTHREADS_NUM=3
##LIBS += -L/opt/intel/lib/intel64/ -liomp5 -openmp

SOURCES += main.cpp \
    atoms/atom.cpp \
    atoms/lattice.cpp \
    generations/atoms/specified_atom.cpp \
    generations/crystals/diamond.cpp \
    generations/crystals/diamond_relations.cpp \
    generations/finder.cpp \
    generations/handbook.cpp \
    generations/reactions/typical/ads_methyl_to_dimer.cpp \
    generations/reactions/typical/des_methyl_from_bridge.cpp \
    generations/reactions/typical/dimer_drop.cpp \
    generations/reactions/typical/dimer_formation.cpp \
    generations/reactions/typical/high_bridge_stand_to_one_bridge.cpp \
    generations/reactions/typical/high_bridge_to_two_bridges.cpp \
    generations/reactions/typical/methyl_on_dimer_hydrogen_migration.cpp \
    generations/reactions/typical/methyl_to_high_bridge.cpp \
    generations/reactions/typical/next_level_bridge_to_high_bridge.cpp \
    generations/reactions/ubiquitous/surface_activation.cpp \
    generations/reactions/ubiquitous/surface_deactivation.cpp \
    generations/species/base/bridge.cpp \
    generations/species/base/dimer.cpp \
    generations/species/base/methyl_on_bridge.cpp \
    generations/species/base/methyl_on_dimer.cpp \
    generations/species/specific/bridge_crs.cpp \
    generations/species/specific/bridge_ctsi.cpp \
    generations/species/specific/dimer_cri_cli.cpp \
    generations/species/specific/dimer_crs.cpp \
    generations/species/specific/high_bridge.cpp \
    generations/species/specific/methyl_on_bridge_cbi_cmu.cpp \
    generations/species/specific/methyl_on_dimer_cls_cmu.cpp \
    generations/species/specific/methyl_on_dimer_cmsu.cpp \
    generations/species/specific/methyl_on_dimer_cmu.cpp \
    mc/base_events_container.cpp \
    mc/common_mc_data.cpp \
    mc/events_container.cpp \
    mc/multi_events_container.cpp \
    phases/amorph.cpp \
    phases/crystal.cpp \
    reactions/mono_spec_reaction.cpp \
    reactions/ubiquitous_reaction.cpp \
    species/base_spec.cpp \
    species/specific_spec.cpp \
    tests/support/open_diamond.cpp \
    tools/common.cpp \
    reactions/spec_reaction.cpp \
    generations/species/specific/bridge_crs_cti_cli.cpp \
    mc/counter.cpp

HEADERS += \
    atoms/atom.h \
    atoms/lattice.h \
    atoms/neighbours.h \
    generations/atoms/c.h \
    generations/atoms/specified_atom.h \
    generations/builders/atom_builder.h \
    generations/crystals/diamond.h \
    generations/crystals/diamond_relations.h \
    generations/finder.h \
    generations/handbook.h \
    generations/names.h \
    generations/reactions/many_typical.h \
    generations/reactions/mono_typical.h \
    generations/reactions/typical/ads_methyl_to_dimer.h \
    generations/reactions/typical/des_methyl_from_bridge.h \
    generations/reactions/typical/dimer_drop.h \
    generations/reactions/typical/dimer_formation.h \
    generations/reactions/typical/high_bridge_stand_to_one_bridge.h \
    generations/reactions/typical/high_bridge_to_two_bridges.h \
    generations/reactions/typical/methyl_on_dimer_hydrogen_migration.h \
    generations/reactions/typical/methyl_to_high_bridge.h \
    generations/reactions/typical/next_level_bridge_to_high_bridge.h \
    generations/reactions/ubiquitous/surface_activation.h \
    generations/reactions/ubiquitous/surface_deactivation.h \
    generations/species/base/bridge.h \
    generations/species/base/dimer.h \
    generations/species/base/methyl_on_bridge.h \
    generations/species/base/methyl_on_dimer.h \
    generations/species/specific/bridge_crs.h \
    generations/species/specific/bridge_ctsi.h \
    generations/species/specific/dimer_cri_cli.h \
    generations/species/specific/dimer_crs.h \
    generations/species/specific/high_bridge.h \
    generations/species/specific/methyl_on_bridge_cbi_cmu.h \
    generations/species/specific/methyl_on_dimer_cls_cmu.h \
    generations/species/specific/methyl_on_dimer_cmsu.h \
    generations/species/specific/methyl_on_dimer_cmu.h \
    mc/base_events_container.h \
    mc/common_mc_data.h \
    mc/events_container.h \
    mc/mc.h \
    mc/multi_events_container.h \
    phases/amorph.h \
    phases/crystal.h \
    phases/phase.h \
    reactions/few_specs_reaction.h \
    reactions/mono_spec_reaction.h \
    reactions/reaction.h \
    reactions/spec_reaction.h \
    reactions/ubiquitous_reaction.h \
    species/additional_atoms_wrapper.h \
    species/atom_shift_wrapper.h \
    species/atoms_swap_wrapper.h \
    species/base_spec.h \
    species/dependent_spec.h \
    species/keeper.h \
    species/specific_spec.h \
    tests/support/open_diamond.h \
    tools/collector.h \
    tools/common.h \
    tools/scavenger.h \
    tools/vector3d.h \
    generations/reactions/typical.h \
    species/source_spec.h \
    generations/species/base.h \
    generations/species/source.h \
    generations/species/dependent.h \
    generations/species/specific.h \
    generations/species/typed.h \
    generations/species/specific/bridge_crs_cti_cli.h \
    mc/counter.h \
    generations/reactions/ubiquitous.h
