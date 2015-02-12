#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include "spec_reaction.h"

namespace vd
{

class TypicalReaction : public SpecReaction
{
public:
    void store() override;
    void remove() override;

protected:
    friend class LateralReaction;

    TypicalReaction() = default;

    virtual void insertToTargets(SpecReaction *reaction) = 0;
    virtual void eraseFromTargets(SpecReaction *reaction) = 0;
};

}

#endif // TYPICAL_REACTION_H
