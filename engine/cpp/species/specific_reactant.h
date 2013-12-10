#ifndef SPECIFIC_REACTANT_H
#define SPECIFIC_REACTANT_H

#include "removable_reactant.h"
#include "specific_spec.h"

namespace vd
{

class SpecificReactant : public RemovableReactant<SpecificSpec>
{
public:
    void remove() override;

protected:
//    using RemovableReactant::RemovableReactant;
    SpecificReactant(BaseSpec *parent) : RemovableReactant(parent) {}
};

}

#endif // SPECIFIC_REACTANT_H
