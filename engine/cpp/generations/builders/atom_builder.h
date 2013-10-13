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
        // TODO: добавить ассерты на проверку соответствия actives и типа атома
        assert(type == 4 || type == 3 || type == 18 || type == 12 || type == 14 || type == 17 || type == 13);
        return new C(type, actives, (Lattice *)0);
    }

    Atom *buildCd(uint type, uint actives, const Crystal *crystal, const int3 &coords)
    {
        // TODO: добавить ассерты на проверку соответствия actives и типа атома
        assert(type == 0 || type == 20 || type == 6 || type == 2 || type == 5 || type == 10 || type == 15 ||
               type == 7 || type == 9 || type == 1 || type == 11 || type == 19 || type == 8);

        return new C(type, actives, new Lattice(crystal, coords));
    }
};

#endif // ATOM_BUILDER_H
