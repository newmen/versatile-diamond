#ifndef LATERAL_SPEC_H
#define LATERAL_SPEC_H

#include "../reactions/lateral_reaction.h"
#include "base_spec.h"
#include "reactant.h"

namespace vd
{

class LateralSpec : public Reactant<BaseSpec, LateralReaction>
{
protected:
    template <class... Args>
    LateralSpec(Args... args) : Reactant(args...) {}
};

}

#endif // LATERAL_SPEC_H
