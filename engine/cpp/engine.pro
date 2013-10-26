TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -g -std=c++0x -fopenmp -DDEBUG -DPRINT
LIBS += -fopenmp -lstdc++

SOURCES += main.cpp \
    atoms/atom.cpp \
    atoms/lattice.cpp \
    generations/atoms/c.cpp \
    generations/atoms/specified_atom.cpp \
    generations/base_specs/bridge.cpp \
    generations/base_specs/dimer.cpp \
    generations/crystals/diamond.cpp \
    generations/crystals/diamond_relations.cpp \
    generations/finder.cpp \
    generations/handbook.cpp \
    generations/reactions/typical/dimer_formation.cpp \
    generations/reactions/ubiquitous/reaction_activation.cpp \
    generations/reactions/ubiquitous/reaction_deactivation.cpp \
    generations/specific_specs/bridge_cts.cpp \
    mc/base_events_container.cpp \
    mc/events_container.cpp \
    mc/multi_events_container.cpp \
    phases/amorph.cpp \
    phases/crystal.cpp \
    phases/phase.cpp \
    species/base_spec.cpp \
    species/reactions_mixin.cpp \
    tools/common.cpp \
    tools/lockable.cpp

HEADERS += \
    atoms/atom.h \
    atoms/concrete_atom.h \
    atoms/lattice.h \
    atoms/neighbours.h \
    atoms/role.h \
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
    generations/reactions/typical/typical_reaction.h \
    generations/reactions/ubiquitous/reaction_activation.h \
    generations/reactions/ubiquitous/reaction_deactivation.h \
    generations/reactions/ubiquitous/ubiquitous_reaction.h \
    generations/specific_specs/bridge_cts.h \
    mc/base_events_container.h \
    mc/events_container.h \
    mc/mc.h \
    mc/multi_events_container.h \
    phases/amorph.h \
    phases/crystal.h \
    phases/phase.h \
    reactions/reaction.h \
    species/base_spec.h \
    species/dependent_spec.h \
    species/keeper.h \
    species/reactions_mixin.h \
    species/source_base_spec.h \
    species/specific_spec.h \
    tools/common.h \
    tools/lockable.h \
    tools/vector3d.h \
    reactions/multi_reaction.h \
    reactions/single_reaction.h
