#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include "../../atoms/atom.h"
using namespace vd;

class SpecifiedAtom : public Atom
{
public:
//    using Atom::Atom;
    SpecifiedAtom(ushort type, ushort actives, Lattice *lattice) : Atom(type, actives, lattice) {}

    bool is(ushort typeOf) const override;
    bool prevIs(ushort typeOf) const override;

    void specifyType() override;
};

#endif // SPECIFIED_ATOM_H
