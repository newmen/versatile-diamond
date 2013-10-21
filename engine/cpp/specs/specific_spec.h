#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include "dependent_spec.h"
#include "reactions_mixin.h"

namespace vd
{

template <ushort PARENTS_NUM>
class SpecificSpec : public DependentSpec<PARENTS_NUM>, public ReactionsMixin
{
public:
    using DependentSpec<PARENTS_NUM>::DependentSpec;
};

}

#endif // SPECIFIC_SPEC_H
