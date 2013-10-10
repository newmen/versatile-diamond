#ifndef PHASE_H
#define PHASE_H

#include "common.h"
#include "crystal.h"

namespace vd
{

class Lattice
{
    const Crystal *_crystal;
    uint3 _coords;

public:
    Lattice(const Crystal *crystal, const uint3 &coords);

    const uint3 &coords() const { return _coords; }
    void updateCoods(const uint3 &coords) { _coords = coords; }
};

}

#endif // PHASE_H
