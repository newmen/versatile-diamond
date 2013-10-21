TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -g -std=c++0x -DDEBUG -fopenmp
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
    specs/base_spec.cpp \
    tools/common.cpp \
    tools/lockable.cpp \
    specs/reactions_mixin.cpp

HEADERS += \
    atoms/atom.h \
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
    generations/handbook.h \
    generations/names.h \
    generations/reactions/typical/dimer_formation.h \
    generations/reactions/ubiquitous/reaction_activation.h \
    generations/reactions/ubiquitous/reaction_deactivation.h \
    generations/specific_specs/bridge_cts.h \
    mc/base_events_container.h \
    mc/events_container.h \
    mc/mc.h \
    mc/multi_events_container.h \
    phases/amorph.h \
    phases/crystal.h \
    phases/phase.h \
    reactions/reaction.h \
    reactions/typical_reaction.h \
    specs/base_spec.h \
    specs/dependent_spec.h \
    specs/source_base_spec.h \
    specs/specific_spec.h \
    tools/common.h \
    tools/lockable.h \
    tools/vector3d.h \
    atoms/concrete_atom.h \
    specs/reactions_mixin.h \
    reactions/ubiquitous_reaction.h
