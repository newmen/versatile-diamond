TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -std=c++0x -DNDEBUG

SOURCES += main.cpp \
    generations/crystals/diamond.cpp \
    atom.cpp \
    crystal.cpp \
    lattice.cpp

HEADERS += \
    generations/builders/diamond_atom_builder.h \
    generations/crystals/diamond.h \
    atom.h \
    common.h \
    vector3d.h \
    crystal.h \
    lattice.h \
    atom_builder.h \
    generations/atoms/c.h \
    neighbours.h \
    generations/lattices/diamond_lattice.h \
    generations/builders/diamond_crystal_builder.h \
    crystal_builder.h

unix:!macx: LIBS += -L/home/newmen/gcc/4.8.0/lib64/ -lstdc++

INCLUDEPATH += /home/newmen/gcc/4.8.0/lib64
DEPENDPATH += /home/newmen/gcc/4.8.0/lib64
