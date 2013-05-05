#ifndef PHASE_H
#define PHASE_H

#include "common.h"
#include "crystal.h"

namespace vd
{

class Lattice
{
    const Crystal *_crystal;
    const uint3 _coords;

public:
    Lattice(const Crystal *crystal, const uint3 &coords);
};

}

#endif // PHASE_H
