#ifndef REACTION_ACTIVATION_H
#define REACTION_ACTIVATION_H

#include "ubiquitous_reaction.h"

class ReactionActivation : public UbiquitousReaction<SURFACE_ACTIVATION>
{
    static const ushort __hToActives[];
    static const ushort __hOnAtoms[];

public:
    static void find(Atom *anchor);

    using UbiquitousReaction::UbiquitousReaction;

    double rate() const { return 3600; }

protected:
    short toType(ushort type) const override;
    const ushort *onAtoms() const override;

    void action() override { target()->activate(); }
};

#endif // REACTION_ACTIVATION_H
