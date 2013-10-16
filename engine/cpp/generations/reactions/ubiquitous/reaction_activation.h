#ifndef REACTION_ACTIVATION_H
#define REACTION_ACTIVATION_H

#include "ubiquitous_reaction.h"

class ReactionActivation : public UbiquitousReaction
{
public:
    using UbiquitousReaction::UbiquitousReaction;

    double rate() const { return 3600; }

protected:
    short toType(uint type) const override;
    void action() override { target()->activate(); }
    void remove() override;
};

#endif // REACTION_ACTIVATION_H
