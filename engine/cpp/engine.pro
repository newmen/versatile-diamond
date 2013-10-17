TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -g -std=c++0x -DDEBUG -fopenmp
LIBS += -fopenmp

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
    generations/dictionary.cpp \
    generations/base_specs/dimer.cpp \
    generations/recipes/base_specs/base_bridge_recipe.cpp \
    generations/recipes/base_specs/base_dimer_recipe.cpp \
    mc/mc.cpp \
    generations/dmc.cpp \
    generations/reactions/ubiquitous/reaction_activation.cpp \
    generations/reactions/ubiquitous/reaction_deactivation.cpp \
    generations/recipes/reactions/ubiquitous/reaction_activation_recipe.cpp \
    generations/recipes/reactions/ubiquitous/reaction_deactivation_recipe.cpp \
    generations/atoms/specified_atom.cpp \
    generations/specific_specs/bridge_cts.cpp \
    generations/recipes/specific_specs/bridge_cts_recipe.cpp \
    locks.cpp

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
    generations/dictionary.h \
    generations/base_specs/dimer.h \
    generations/recipes/base_specs/base_bridge_recipe.h \
    generations/recipes/base_specs/base_dimer_recipe.h \
    mc/mc.h \
    mc/events_container.h \
    generations/dmc.h \
    reaction.h \
    generations/reactions/ubiquitous/ubiquitous_reaction.h \
    generations/reactions/ubiquitous/reaction_activation.h \
    generations/reactions/ubiquitous/reaction_deactivation.h \
    generations/recipes/reactions/ubiquitous/ubiquitous_reaction_recipe.h \
    generations/recipes/reactions/ubiquitous/reaction_activation_recipe.h \
    generations/recipes/reactions/ubiquitous/reaction_deactivation_recipe.h \
    generations/atoms/specified_atom.h \
    generations/specific_specs/bridge_cts.h \
    generations/recipes/specific_specs/bridge_cts_recipe.h \
    generations/recipes/atomic_recipe.h \
    locks.h

unix:!macx: LIBS += -L/home/newmen/gcc/4.8.0/lib64/ -lstdc++

INCLUDEPATH += /home/newmen/gcc/4.8.0/lib64
DEPENDPATH += /home/newmen/gcc/4.8.0/lib64
