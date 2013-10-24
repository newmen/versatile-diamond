#ifndef MULTI_REACTION_H
#define MULTI_REACTION_H

#include "reaction.h"

namespace vd
{

class MultiReaction : public Reaction
{
public:
    virtual Atom *target() = 0;
};

}

#endif // MULTI_REACTION_H
