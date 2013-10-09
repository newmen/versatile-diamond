TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -std=c++0x

SOURCES += main.cpp \
    generations/crystals/diamond.cpp \
    atom.cpp \
    crystal.cpp \
    lattice.cpp

HEADERS += \
    generations/crystals/diamond.h \
    atom.h \
    common.h \
    vector3d.h \
    crystal.h \
    lattice.h \
    atom_builder.h \
    generations/builders/diamond_atom_builder.h

unix:!macx: LIBS += -L/home/newmen/gcc/4.8.0/lib64/ -lstdc++

INCLUDEPATH += /home/newmen/gcc/4.8.0/lib64
DEPENDPATH += /home/newmen/gcc/4.8.0/lib64
