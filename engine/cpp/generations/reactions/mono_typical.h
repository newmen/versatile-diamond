#ifndef MONO_TYPICAL_H
#define MONO_TYPICAL_H

#include "../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT>
class MonoTypical : public Typical<MonoSpecReaction, RT>
{
public:
    template <class R, ushort ATOMS_NUM>
    static void find(SpecificSpec *target, const ushort *indexes, const ushort *types);

protected:
//    using Typical<MonoSpecReaction, RT>::Typical;
    MonoTypical(SpecificSpec *target) : Typical<MonoSpecReaction, RT>(target) {}
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

#ifndef DEBUG
        if (result) break;
#endif // DEBUG
    }

    if (result)
    {
        SpecReaction *reaction = new R(target);
        reaction->store();
    }
}

#endif // MONO_TYPICAL_H
