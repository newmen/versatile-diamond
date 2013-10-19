TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -g -std=c++0x -DDEBUG -fopenmp
LIBS += -fopenmp -lstdc++

SOURCES += main.cpp \
    atom.cpp \
    crystal.cpp \
    lattice.cpp \
    common.cpp \
    generations/crystals/diamond.cpp \
    amorph.cpp \
    phase.cpp \
    generations/atoms/c.cpp \
    base_spec.cpp \
    generations/base_specs/bridge.cpp \
    generations/crystals/diamond_relations.cpp \
    generations/base_specs/dimer.cpp \
    generations/reactions/ubiquitous/reaction_activation.cpp \
    generations/reactions/ubiquitous/reaction_deactivation.cpp \
    generations/atoms/specified_atom.cpp \
    generations/specific_specs/bridge_cts.cpp \
    locks.cpp \
    lockable.cpp \
    generations/handbook.cpp \
    generations/reactions/typical/dimer_formation.cpp \
    mc/base_events_container.cpp \
    generations/reactions/ubiquitous/ubiquitous_reaction.cpp \
    mc/events_container.cpp \
    mc/multi_events_container.cpp

HEADERS += \
    generations/crystals/diamond.h \
    atom.h \
    common.h \
    vector3d.h \
    crystal.h \
    lattice.h \
    generations/atoms/c.h \
    neighbours.h \
    generations/crystals/diamond_relations.h \
    amorph.h \
    phase.h \
    generations/builders/atom_builder.h \
    base_spec.h \
    generations/base_specs/bridge.h \
    generations/base_specs/dimer.h \
    mc/mc.h \
    mc/events_container.h \
    reaction.h \
    generations/reactions/ubiquitous/ubiquitous_reaction.h \
    generations/reactions/ubiquitous/reaction_activation.h \
    generations/reactions/ubiquitous/reaction_deactivation.h \
    generations/atoms/specified_atom.h \
    generations/specific_specs/bridge_cts.h \
    locks.h \
    lockable.h \
    generations/names.h \
    generations/handbook.h \
    generations/reactions/typical/dimer_formation.h \
    generations/reactions/typical/typical_reaction.h \
    dependent_spec.h \
    role.h \
    source_base_spec.h \
    mc/base_events_container.h \
    mc/multi_events_container.h
