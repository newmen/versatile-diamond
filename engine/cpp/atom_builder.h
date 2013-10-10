#ifndef ATOM_BUILDER_H
#define ATOM_BUILDER_H

#include "atom.h"
#include "crystal.h"

namespace vd
{

class AtomBuilder
{
public:
    virtual Atom *buildAmorphC(uint type) = 0;
    virtual Atom *buildCrystalC(uint type, const Crystal *crystal, const uint3 &coords) = 0;
};

}

#endif // ATOM_BUILDER_H
