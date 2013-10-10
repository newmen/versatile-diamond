#ifndef DIAMOND_LATTICE_H
#define DIAMOND_LATTICE_H

#include "../../lattice.h"
#include "../../neighbours.h"

using namespace vd;

class DL
{
public:
    Neighbours<2> front_100() const
    {

    }
};

class DiamondLattice : public Lattice<DL>
{
};

#endif // DIAMOND_LATTICE_H
