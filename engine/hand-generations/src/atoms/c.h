#ifndef C_H
#define C_H

#include "specified_atom.h"

class C : public SpecifiedAtom<4>
{
    static const char __name[];

public:
    C(ushort type, ushort actives, Atom::OriginalLattice *lattice) :
        SpecifiedAtom(type, actives, lattice) {}

    const char *name() const final { return __name; }
};

#endif // C_H
