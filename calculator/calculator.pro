TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -std=c++0x

SOURCES += main.cpp \
    generation/defaultcompositionbuilder.cpp \
    crystals/diamond.cpp \
    atom.cpp \
    compositionbuilder.cpp \
    crystal.cpp \
    lattice.cpp

HEADERS += \
    generation/defaultcompositionbuilder.h \
    crystals/diamond.h \
    atom.h \
    common.h \
    vector3d.h \
    compositionbuilder.h \
    crystal.h \
    lattice.h

unix:!macx: LIBS += -L/home/newmen/gcc/4.8.0/lib64/ -lstdc++

INCLUDEPATH += /home/newmen/gcc/4.8.0/lib64
DEPENDPATH += /home/newmen/gcc/4.8.0/lib64
