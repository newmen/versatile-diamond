#ifndef DIAMOND_ATOM_BUILDER_H
#define DIAMOND_ATOM_BUILDER_H

#include <vector>
#include "../../atom_builder.h"
#include "../../lattice.h"

#include "../atoms/c.h"

#include <assert.h>

using namespace vd;

class DiamondAtomBuilder : public AtomBuilder
{
public:
    Atom *buildAmorphC(uint type)
    {
        return new C(type);
    }

    Atom *buildCrystalC(uint type, const Crystal *crystal, const uint3 &coords)
    {
        assert(type != 0 && type != 20 && type != 6 && type != 2 && type != 5 && type != 10 && type != 15 &&
               type != 7 && type != 9 && type != 1 && type != 11 && type != 19 && type != 8);

        return new C(type, new Lattice(crystal, coords));
    }
};

#endif // DIAMOND_ATOM_BUILDER_H
