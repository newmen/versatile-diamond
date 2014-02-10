#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

#include "../tools/creator.h"
#include "reaction.h"

namespace vd
{

class SpecReaction : public Reaction, public Creator
{
public:
    virtual void store() = 0;
    virtual void remove() = 0;

protected:
    SpecReaction() = default;
};

}

#endif // SINGLE_REACTION_H
