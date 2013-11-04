TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

#QMAKE_CXXFLAGS += -D_GLIBCXX_DEBUG_PEDANTIC
QMAKE_CXXFLAGS += -DDEBUG
#QMAKE_CXXFLAGS += -DPRINT

QMAKE_CXXFLAGS += -std=c++0x
QMAKE_CXXFLAGS += -DPARALLEL -fopenmp
LIBS += -fopenmp -lstdc++

#QMAKE_CXXFLAGS += -std=c++11
#QMAKE_CXXFLAGS += -DPARALLEL -openmp
#LIBS += -L/opt/intel/lib/intel64/ -liomp5 -openmp

SOURCES += main.cpp \
    atoms/atom.cpp \
    atoms/lattice.cpp \
    generations/base_specs/bridge.cpp \
    generations/base_specs/dimer.cpp \
    generations/crystals/diamond.cpp \
    generations/crystals/diamond_relations.cpp \
    generations/finder.cpp \
    generations/handbook.cpp \
    generations/reactions/typical/dimer_formation.cpp \
    generations/reactions/ubiquitous/surface_activation.cpp \
    generations/reactions/ubiquitous/surface_deactivation.cpp \
    mc/base_events_container.cpp \
    mc/events_container.cpp \
    mc/multi_events_container.cpp \
    phases/amorph.cpp \
    phases/crystal.cpp \
    phases/phase.cpp \
    reactions/mono_spec_reaction.cpp \
    reactions/ubiquitous_reaction.cpp \
    species/base_spec.cpp \
    tests/support/open_diamond.cpp \
    tools/common.cpp \
    tools/lockable.cpp \
    generations/reactions/typical/dimer_drop.cpp \
    generations/specific_specs/dimer_cri_cli.cpp \
    species/specific_spec.cpp \
    generations/specific_specs/bridge_ctsi.cpp \
    generations/specific_specs/dimer_crs.cpp \
    generations/atoms/specified_atom.cpp \
    generations/reactions/typical/ads_methyl_to_dimer.cpp \
    generations/base_specs/methyl_on_dimer.cpp \
    generations/reactions/typical/methyl_to_high_bridge.cpp \
    generations/reactions/typical/methyl_on_dimer_hydrogen_migration.cpp \
    generations/specific_specs/methyl_on_dimer_cls_cmu.cpp \
    generations/specific_specs/methyl_on_dimer_cmsu.cpp \
    generations/specific_specs/methyl_on_dimer_cmu.cpp \
    generations/base_specs/methyl_on_bridge.cpp \
    generations/specific_specs/methyl_on_bridge_cbi_cmu.cpp \
    generations/reactions/typical/des_methyl_from_bridge.cpp

HEADERS += \
    atoms/atom.h \
    atoms/lattice.h \
    atoms/neighbours.h \
    generations/atoms/c.h \
    generations/atoms/specified_atom.h \
    generations/base_specs/bridge.h \
    generations/base_specs/dimer.h \
    generations/builders/atom_builder.h \
    generations/crystals/diamond.h \
    generations/crystals/diamond_relations.h \
    generations/finder.h \
    generations/handbook.h \
    generations/names.h \
    generations/reactions/typical/dimer_formation.h \
    generations/reactions/ubiquitous/surface_activation.h \
    generations/reactions/ubiquitous/surface_deactivation.h \
    mc/base_events_container.h \
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
    species/base_spec.h \
    species/dependent_spec.h \
    species/keeper.h \
    species/source_base_spec.h \
    species/specific_spec.h \
    tests/support/open_diamond.h \
    tools/collector.h \
    tools/common.h \
    tools/lockable.h \
    tools/scavenger.h \
    tools/vector3d.h \
    generations/reactions/typical/dimer_drop.h \
    generations/specific_specs/dimer_cri_cli.h \
    generations/specific_specs/bridge_ctsi.h \
    generations/specific_specs/dimer_crs.h \
    generations/reactions/typical/ads_methyl_to_dimer.h \
    generations/base_specs/methyl_on_dimer.h \
    species/atom_shifter_wrapper.h \
    species/additional_atoms_wrapper.h \
    generations/reactions/typical/methyl_to_high_bridge.h \
    generations/reactions/typical/methyl_on_dimer_hydrogen_migration.h \
    generations/specific_specs/methyl_on_dimer_cls_cmu.h \
    generations/specific_specs/methyl_on_dimer_cmsu.h \
    generations/specific_specs/methyl_on_dimer_cmu.h \
    generations/base_specs/methyl_on_bridge.h \
    generations/specific_specs/methyl_on_bridge_cbi_cmu.h \
    generations/reactions/typical/des_methyl_from_bridge.h
