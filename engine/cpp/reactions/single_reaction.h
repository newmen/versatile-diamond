#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

//#include "../tools/lockable.h"
#include "reaction.h"

namespace vd
{

class ReactionsMixin; //

class SingleReaction : public Reaction //, public Lockable
{
public:
    virtual void removeFrom(ReactionsMixin *target) = 0;
//    virtual void removeExcept(ReactionsMixin *) = 0;
//    virtual ReactionsMixion *anotherTargets(ReactionsMixin *target) = 0;
};

}

#endif // SINGLE_REACTION_H
