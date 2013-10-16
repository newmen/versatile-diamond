#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include "../../atom.h"
using namespace vd;

#include "../dictionary.h"
#include "../recipes/reactions/ubiquitous/reaction_activation_recipe.h"
#include "../recipes/reactions/ubiquitous/reaction_deactivation_recipe.h"

template <uint VALENCE>
class SpecifiedAtom : public ConcreteAtom<VALENCE>
{
public:
    using ConcreteAtom<VALENCE>::ConcreteAtom;

    bool is(uint typeOf) const override;
    bool prevIs(uint typeOf) const override;

    void specifyType() override;
    void findChildren() override;
};

template <uint VALENCE>
bool SpecifiedAtom<VALENCE>::is(uint typeOf) const
{
    return Dictionary::atomIs(Atom::type(), typeOf);
}

template <uint VALENCE>
bool SpecifiedAtom<VALENCE>::prevIs(uint typeOf) const
{
    return Atom::prevType() != (uint)(-1) && Dictionary::atomIs(Atom::prevType(), typeOf);
}

template <uint VALENCE>
void SpecifiedAtom<VALENCE>::specifyType()
{
    Atom::setType(Dictionary::specificate(Atom::type()));
}

template <uint VALENCE>
void SpecifiedAtom<VALENCE>::findChildren()
{
    ReactionActivationRecipe rar;
    rar.find(this);

    ReactionDeactivationRecipe rdr;
    rdr.find(this);
}

#endif // SPECIFIED_ATOM_H
