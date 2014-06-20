#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include <atoms/atom.h>
using namespace vd;

#include "../handbook.h"

template <ushort VALENCE>
class SpecifiedAtom : public Atom
{
public:
    SpecifiedAtom(ushort type, ushort actives, Lattice *lattice) : Atom(type, actives, lattice) {}

    bool is(ushort typeOf) const final;
    bool prevIs(ushort typeOf) const final;

    void specifyType() final;

    ushort valence() const final { return VALENCE; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort VALENCE>
bool SpecifiedAtom<VALENCE>::is(ushort typeOf) const
{
    return type() != NO_VALUE && Handbook::atomIs(type(), typeOf);
}

template <ushort VALENCE>
bool SpecifiedAtom<VALENCE>::prevIs(ushort typeOf) const
{
    return prevType() != NO_VALUE && Handbook::atomIs(prevType(), typeOf);
}

template <ushort VALENCE>
void SpecifiedAtom<VALENCE>::specifyType()
{
    Atom::setType(Handbook::specificate(type()));
}

#endif // SPECIFIED_ATOM_H
