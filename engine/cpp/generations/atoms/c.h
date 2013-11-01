#ifndef C_H
#define C_H

#include "specified_atom.h"

class C : public SpecifiedAtom
{
public:
//    using SpecifiedAtom::SpecifiedAtom;
    C(ushort type, ushort actives, Lattice *lattice) : SpecifiedAtom(type, actives, lattice) {}
};

#endif // C_H
