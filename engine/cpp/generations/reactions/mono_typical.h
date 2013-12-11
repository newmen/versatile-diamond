#ifndef MONO_TYPICAL_H
#define MONO_TYPICAL_H

#include "../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT>
class MonoTypical : public Typical<MonoSpecReaction, RT>
{
    typedef Typical<MonoSpecReaction, RT> ParentType;

protected:
    MonoTypical(SpecificSpec *target) : ParentType(target) {}
};

#endif // MONO_TYPICAL_H
