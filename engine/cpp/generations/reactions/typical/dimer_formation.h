#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../../reactions/typical_reaction.h"

class DimerFormation : public TypicalReaction<DIMER_FORMATION, 2>
{
public:
    static void find(BaseSpec *parent);

    using TypicalReaction::TypicalReaction;

    double rate() const { return 1e5; }
    void doIt();
};

#endif // DIMERFORMATION_H
