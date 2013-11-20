#ifndef MONO_TYPICAL_H
#define MONO_TYPICAL_H

#include "../../reactions/mono_spec_reaction.h"
#include "../../reactions/target_atoms.h"
using namespace vd;

#include "typical.h"

template <ushort RT>
class MonoTypical : public Typical<MonoSpecReaction, RT>
{
protected:
    template <class R>
    static void find(const TargetAtoms &ta);

//    using Typical<MonoSpecReaction, RT>::Typical;
    MonoTypical(SpecificSpec *target) : Typical<MonoSpecReaction, RT>(target) {}
};

template <ushort RT>
template <class R>
void MonoTypical<RT>::find(const TargetAtoms &ta)
{
//    if (ta.isUpdated()) return;

    SpecReaction *reaction = new R(ta.target());
    reaction->store();
}

#endif // MONO_TYPICAL_H
