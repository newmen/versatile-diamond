#ifndef SINGLE_LATERAL_REACTION_H
#define SINGLE_LATERAL_REACTION_H

#include "lateral_reaction.h"

namespace vd
{

class SingleLateralReaction : public LateralReaction
{
protected:
    template <class... Args>
    SingleLateralReaction(Args... args) : LateralReaction(args...) {}

public:
    virtual bool haveTarget(LateralSpec *spec) const = 0;

    virtual void insertToLateralTargets(LateralReaction *reaction) = 0;
    virtual void eraseFromLateralTargets(LateralReaction *reaction) = 0;
};

}

#endif // SINGLE_LATERAL_REACTION_H
