TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -std=c++0x -DDEBUG -fopenmp
LIBS += -fopenmp

SOURCES += main.cpp \
    atom.cpp \
    crystal.cpp \
    lattice.cpp \
    common.cpp \
    generations/crystals/diamond.cpp

HEADERS += \
    generations/builders/diamond_atom_builder.h \
    generations/crystals/diamond.h \
    atom.h \
    common.h \
    vector3d.h \
    crystal.h \
    lattice.h \
    generations/atoms/c.h \
    neighbours.h \
    generations/crystals/diamond_relations.h

unix:!macx: LIBS += -L/home/newmen/gcc/4.8.0/lib64/ -lstdc++

INCLUDEPATH += /home/newmen/gcc/4.8.0/lib64
DEPENDPATH += /home/newmen/gcc/4.8.0/lib64
