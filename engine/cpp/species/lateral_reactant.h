#ifndef LATERAL_REACTANT_H
#define LATERAL_REACTANT_H

#include "lateral_spec.h"
#include "removable_reactant.h"

namespace vd
{

class LateralReactant : public RemovableReactant<LateralSpec>
{
public:
//    using RemovableReactant::RemovableReactant;
    LateralReactant(ParentSpec *parent) : RemovableReactant(parent) {}



    // TODO: !!!!!!

    void store() override {}
    void remove() override {}

protected:
    void findAllReactions() override {}
};

}

#endif // LATERAL_REACTANT_H
