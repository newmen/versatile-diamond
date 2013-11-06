#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

#include "reaction.h"

namespace vd
{

class SpecificSpec; //

class SpecReaction : public Reaction
{
public:
    virtual void store() = 0;
    virtual void removeFrom(SpecificSpec *target) = 0;

protected:
    virtual void remove() = 0;
};

}

#endif // SINGLE_REACTION_H
