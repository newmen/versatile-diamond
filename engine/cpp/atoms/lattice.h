#ifndef LATTICE_H
#define LATTICE_H

#include "../tools/common.h"
#include "../phases/crystal.h"

namespace vd
{

class Lattice
{
    Crystal *_crystal;
    int3 _coords;

public:
    Lattice(Crystal *crystal, const int3 &coords);

    Crystal *crystal() { return _crystal; }
    const Crystal *crystal() const { return _crystal; }
    const int3 &coords() const { return _coords; }
    void updateCoords(const int3 &coords) { _coords = coords; }
};

}

#endif // LATTICE_H
