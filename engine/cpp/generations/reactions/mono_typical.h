#ifndef MONO_TYPICAL_H
#define MONO_TYPICAL_H

#include "../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT>
class MonoTypical : public Typical<MonoSpecReaction, RT>
{
protected:
    template <class R>
    static void find(SpecificSpec *target, const ushort *indexes, const ushort *types, ushort atomsNum);

//    using Typical<MonoSpecReaction, RT>::Typical;
    MonoTypical(SpecificSpec *target) : Typical<MonoSpecReaction, RT>(target) {}
};

template <ushort RT>
template <class R>
void MonoTypical<RT>::find(SpecificSpec *target, const ushort *indexes, const ushort *types, ushort atomsNum)
{
    if (Typical<MonoSpecReaction, RT>::find(target, indexes, types, atomsNum))
    {
        SpecReaction *reaction = new R(target);
        reaction->store();
    }
}

#endif // MONO_TYPICAL_H
