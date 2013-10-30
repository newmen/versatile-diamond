#ifndef C_H
#define C_H

#include "specified_atom.h"

class C : public SpecifiedAtom<4>
{
public:
//    using SpecifiedAtom::SpecifiedAtom;
    C(ushort type, ushort actives, Lattice *lattice) : SpecifiedAtom<4>(type, actives, lattice) {}
};

#endif // C_H
