#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

#include "reaction.h"

namespace vd
{

class ReactionsMixin; //

class SpecReaction : public Reaction
{
public:
    virtual void removeFrom(ReactionsMixin *target) = 0;

protected:
    virtual void remove() = 0;
};

}

#endif // SINGLE_REACTION_H
