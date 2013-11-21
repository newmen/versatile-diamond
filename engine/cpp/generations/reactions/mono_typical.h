#ifndef MONO_TYPICAL_H
#define MONO_TYPICAL_H

#include "../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT>
class MonoTypical : public Typical<MonoSpecReaction, RT>
{
protected:
//    using Typical<MonoSpecReaction, RT>::Typical;
    MonoTypical(SpecificSpec *target) : Typical<MonoSpecReaction, RT>(target) {}
};

#endif // MONO_TYPICAL_H
