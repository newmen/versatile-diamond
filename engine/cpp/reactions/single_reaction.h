#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

#include "reaction.h"

namespace vd
{

class ReactionsMixin; //

class SingleReaction : public Reaction
{
public:
    virtual void removeExcept(ReactionsMixin *) = 0;
};

}

#endif // SINGLE_REACTION_H
