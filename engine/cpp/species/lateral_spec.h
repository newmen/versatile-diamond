#ifndef LATERAL_SPEC_H
#define LATERAL_SPEC_H

#include "reactant.h"

namespace vd
{

class LateralReaction;

class LateralSpec : public Reactant<LateralReaction>
{
public:
    void remove() override;
};

}

#endif // LATERAL_SPEC_H
