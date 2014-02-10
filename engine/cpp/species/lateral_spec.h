#ifndef LATERAL_SPEC_H
#define LATERAL_SPEC_H

#include "reactant.h"

namespace vd
{

class LateralReaction;

class LateralSpec : public Reactant<LateralReaction>
{
public:
    void findLateralReactions();

protected:
    LateralSpec() = default;

    virtual void findAllLateralReactions() = 0;

    void unconcretizeReactions();
};

}

#endif // LATERAL_SPEC_H
