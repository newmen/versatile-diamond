TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -std=c++0x
QMAKE_CXXFLAGS += -g -DDEBUG
#QMAKE_CXXFLAGS += -D_GLIBCXX_DEBUG_PEDANTIC
#QMAKE_CXXFLAGS += -DPRINT
QMAKE_CXXFLAGS += -DPARALLEL -fopenmp
LIBS += -fopenmp -lstdc++

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
    generations/specific_specs/bridge_cts.cpp \
    mc/base_events_container.cpp \
    mc/events_container.cpp \
    mc/multi_events_container.cpp \
    phases/amorph.cpp \
    phases/crystal.cpp \
    phases/phase.cpp \
    reactions/mono_spec_reaction.cpp \
    reactions/ubiquitous_reaction.cpp \
    species/base_spec.cpp \
    species/reactions_mixin.cpp \
    tests/support/open_diamond.cpp \
    tools/common.cpp \
    tools/lockable.cpp

HEADERS += \
    atoms/atom.h \
    atoms/concrete_atom.h \
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
    generations/specific_specs/bridge_cts.h \
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
    reactions/scavenger.h \
    reactions/spec_reaction.h \
    reactions/ubiquitous_reaction.h \
    species/base_spec.h \
    species/dependent_spec.h \
    species/keeper.h \
    species/reactions_mixin.h \
    species/source_base_spec.h \
    species/specific_spec.h \
    tests/support/open_diamond.h \
    tools/collector.h \
    tools/common.h \
    tools/lockable.h \
    tools/vector3d.h
