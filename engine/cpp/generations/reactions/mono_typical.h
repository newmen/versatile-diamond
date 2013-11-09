#ifndef MONO_TYPICAL_H
#define MONO_TYPICAL_H

#include "../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../handbook.h"

template <ushort RT>
class MonoTypical : public MonoSpecReaction
{
public:
    template <class R, ushort ATOMS_NUM>
    static void find(SpecificSpec *target, const ushort *indexes, const ushort *types);

//    using MonoSpecReaction::FewSpecsReaction;
    MonoTypical(SpecificSpec *target) : MonoSpecReaction(target) {}

    void store() override;

protected:
    void remove() override;
};

template <ushort RT>
template <class R, ushort ATOMS_NUM>
void MonoTypical<RT>::find(SpecificSpec *target, const ushort *indexes, const ushort *types)
{
    bool result = false;
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        Atom *anchor = target->atom(indexes[i]);
        assert(anchor->is(types[i]));

        result = result || !anchor->prevIs(types[i]);
    }

    if (result)
    {
        SpecReaction *reaction = new R(target);
        reaction->store();
    }
}

template <ushort RT>
void MonoTypical<RT>::store()
{
    Handbook::mc().add<RT>(this);
}

template <ushort RT>
void MonoTypical<RT>::remove()
{
    Handbook::mc().remove<RT>(this);
}

#endif // MONO_TYPICAL_H
