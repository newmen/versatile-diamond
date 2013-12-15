#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include "../../atoms/atom.h"
using namespace vd;

#include "../handbook.h"

template <ushort VALENCE>
class SpecifiedAtom : public Atom
{
public:
    SpecifiedAtom(ushort type, ushort actives, Lattice *lattice) : Atom(type, actives, lattice) {}

    bool is(ushort typeOf) const override;
    bool prevIs(ushort typeOf) const override;

    void specifyType() override;

#ifdef DEBUG
    ushort valence() const override { return VALENCE; }
#endif // DEBUG
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <ushort VALENCE>
bool SpecifiedAtom<VALENCE>::is(ushort typeOf) const
{
    return Atom::type() != NO_VALUE && Handbook::atomIs(Atom::type(), typeOf);
}

template <ushort VALENCE>
bool SpecifiedAtom<VALENCE>::prevIs(ushort typeOf) const
{
    return Atom::prevType() != NO_VALUE && Handbook::atomIs(Atom::prevType(), typeOf);
}

template <ushort VALENCE>
void SpecifiedAtom<VALENCE>::specifyType()
{
    Atom::setType(Handbook::specificate(Atom::type()));
}

#endif // SPECIFIED_ATOM_H
