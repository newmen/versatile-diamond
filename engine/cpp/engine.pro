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
    generations/recipes/base_bridge_recipe.cpp \
    generations/dictionary.cpp \
    generations/base_specs/dimer.cpp \
    generations/recipes/base_dimer_recipe.cpp

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
    generations/recipes/base_bridge_recipe.h \
    generations/dictionary.h \
    generations/base_specs/dimer.h \
    generations/recipes/base_dimer_recipe.h

unix:!macx: LIBS += -L/home/newmen/gcc/4.8.0/lib64/ -lstdc++

INCLUDEPATH += /home/newmen/gcc/4.8.0/lib64
DEPENDPATH += /home/newmen/gcc/4.8.0/lib64
