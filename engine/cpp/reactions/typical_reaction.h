#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include "spec_reaction.h"

namespace vd
{

class TypicalReaction : public SpecReaction
{
public:
    void store() override { insertToTargets(this); }
    void remove() override { eraseFromTargets(this); }

protected:
    friend class LateralReaction;

    virtual void insertToTargets(SpecReaction *reaction) = 0;
    virtual void eraseFromTargets(SpecReaction *reaction) = 0;
};

}

#endif // TYPICAL_REACTION_H
