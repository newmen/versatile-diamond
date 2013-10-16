#ifndef ATOM_BUILDER_H
#define ATOM_BUILDER_H

#include <vector>
#include "../atoms/c.h"
#include "../../lattice.h"

#include <assert.h>

using namespace vd;

class AtomBuilder
{
public:
    Atom *buildC(uint type, uint actives)
    {
        return new C(type, actives, (Lattice *)0);
    }

    Atom *buildCd(uint type, uint actives, const Crystal *crystal, const int3 &coords)
    {
        return new C(type, actives, new Lattice(crystal, coords));
    }
};

#endif // ATOM_BUILDER_H
