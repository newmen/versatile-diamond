TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS += -std=c++11

SOURCES += \
    tests/main.cpp \
    wrapper.cpp

HEADERS += \
    assoc_graph.h \
    graph.h \
    hanser_recursive.h \
    object_id.h \
    wrapper.h \
    unordered_set_operations.h
