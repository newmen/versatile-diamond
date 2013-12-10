#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include "../reactions/spec_reaction.h"
#include "dependent_spec.h"
#include "reactant.h"

namespace vd
{

class SpecificSpec : public Reactant<DependentSpec<1>, SpecReaction>
{
protected:
//    using Reactant::Reactant;
    SpecificSpec(BaseSpec *parent) : Reactant(&parent) {}
};

}

#endif // SPECIFIC_SPEC_H
