#ifndef MANY_TYPICAL_H
#define MANY_TYPICAL_H

#include <functional>
#include "../../reactions/few_specs_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT, ushort TARGETS_NUM>
class ManyTypical : public Typical<FewSpecsReaction<TARGETS_NUM>, RT>
{
    typedef Typical<FewSpecsReaction<TARGETS_NUM>, RT> ParentType;

protected:
    ManyTypical(SpecificSpec **targets) : ParentType(targets) {}
};

#endif // MANY_TYPICAL_H
