#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include "../../atoms/concrete_atom.h"
using namespace vd;

#include "../handbook.h"

template <ushort VALENCE>
class SpecifiedAtom : public ConcreteAtom<VALENCE>
{
public:
//    using ConcreteAtom<VALENCE>::ConcreteAtom;
    SpecifiedAtom(ushort type, ushort actives, Lattice *lattice);

    bool is(ushort typeOf) const override;
    bool prevIs(ushort typeOf) const override;

    void specifyType() override;
//    void findChildren() override;
};

template <ushort VALENCE>
SpecifiedAtom<VALENCE>::SpecifiedAtom(ushort type, ushort actives, Lattice *lattice) : ConcreteAtom<VALENCE>(type, actives, lattice)
{
}

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

//template <ushort VALENCE>
//void SpecifiedAtom<VALENCE>::findChildren()
//{
//    ReactionActivation::find(this);
//    ReactionDeactivation::find(this);
//}

#endif // SPECIFIED_ATOM_H
