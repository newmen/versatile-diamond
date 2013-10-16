#ifndef REACTION_DEACTIVATION_H
#define REACTION_DEACTIVATION_H

#include "ubiquitous_reaction.h"

class ReactionDeactivation : public UbiquitousReaction
{
public:
    using UbiquitousReaction::UbiquitousReaction;

    double rate() const { return 2000; }

protected:
    short toType(uint type) const override;
    void action() override { target()->deactivate(); }
    void remove() override;
};

#endif // REACTION_DEACTIVATION_H
