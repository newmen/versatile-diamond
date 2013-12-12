#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

#include "../tools/creator.h"
#include "reaction.h"

namespace vd
{

class SpecificSpec;

class SpecReaction : public Reaction, public Creator
{
public:
    virtual void store() = 0;
    virtual void removeFrom(SpecificSpec *target) = 0;
    virtual void removeFromAll() = 0;

protected:
    virtual void remove() = 0;
};

}

#endif // SINGLE_REACTION_H
