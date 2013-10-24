#ifndef REACTION_DEACTIVATION_H
#define REACTION_DEACTIVATION_H

#include "ubiquitous_reaction.h"

class ReactionDeactivation : public UbiquitousReaction<SURFACE_DEACTIVATION>
{
    static const ushort __activesOnAtoms[];
    static const ushort __activesToH[];

public:
    static void find(Atom *anchor);

    using UbiquitousReaction::UbiquitousReaction;

    double rate() const { return 2000; }

protected:
    short toType(ushort type) const override;
    void action() override { target()->deactivate(); }
};

#endif // REACTION_DEACTIVATION_H
