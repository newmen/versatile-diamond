#ifndef C_H
#define C_H

#include "../../atom.h"

#define VALENCE 4

class C : public ConcreteAtom<VALENCE>
//class C : public IAtom
{
public:
    using ConcreteAtom<VALENCE>::ConcreteAtom;
//    using IAtom::IAtom;
//    C(uint type, Lattice *lattice) : IAtom(type, lattice) {}

    void findSpecs() {}
};

#endif // C_H
