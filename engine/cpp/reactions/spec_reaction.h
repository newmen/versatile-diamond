#ifndef SINGLE_REACTION_H
#define SINGLE_REACTION_H

#include "../tools/creator.h"
#include "reaction.h"

namespace vd
{

class SpecReaction : public Reaction, public Creator
{
public:
    virtual void store() { mcRemember(); }
    virtual void remove() { mcForget(); }

protected:
    SpecReaction() = default;

    virtual void mcRemember() = 0;
    virtual void mcForget() = 0;
};

}

#endif // SINGLE_REACTION_H
