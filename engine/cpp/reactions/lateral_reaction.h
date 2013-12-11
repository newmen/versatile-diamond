#ifndef LATERAL_REACTION_H
#define LATERAL_REACTION_H

#include "spec_reaction.h"

namespace vd
{

class LateralSpec;

class LateralReaction : public SpecReaction
{
public:
    virtual void removeFrom(LateralSpec *spec) = 0;
};

}

#endif // LATERAL_REACTION_H
