#ifndef LATTICE_H
#define LATTICE_H

#include "common.h"
#include "crystal.h"

namespace vd
{

class Lattice
{
    const Crystal *_crystal;
    int3 _coords;

public:
    Lattice(const Crystal *crystal, const int3 &coords);

    bool is(const Crystal *crystal) { return _crystal == crystal; }
    const int3 &coords() const { return _coords; }
    void updateCoords(const int3 &coords) { _coords = coords; }
};

}

#endif // LATTICE_H
