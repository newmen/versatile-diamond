#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include <atoms/atom.h>
using namespace vd;

#include "../handbook.h"

template <ushort VALENCE>
class SpecifiedAtom : public Atom
{
public:
    SpecifiedAtom(ushort type, ushort actives, Atom::OriginalLattice *lattice) :
        Atom(type, actives, lattice) {}

    bool is(ushort typeOf) const final;
    bool prevIs(ushort typeOf) const final;

    void specifyType() final;

    ushort valence() const final { return VALENCE; }
    ushort hCount() const final;
#ifndef NDEBUG
    ushort actives() const final;
#endif // NDEBUG
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

template <ushort VALENCE>
ushort SpecifiedAtom<VALENCE>::hCount() const
{
#ifndef NDEBUG
    Atom::hCount();
#endif // NDEBUG
    return Handbook::hydrogensFor(type());
}

#ifndef NDEBUG
template <ushort VALENCE>
ushort SpecifiedAtom<VALENCE>::actives() const
{
    ushort result = Handbook::activesFor(type());
    assert(Atom::actives() == result);
    return result;
}
#endif // NDEBUG

#endif // SPECIFIED_ATOM_H
