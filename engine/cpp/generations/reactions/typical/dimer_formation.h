#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "typical_reaction.h"

class DimerFormation : TypicalReaction<2>
{
public:
    static void find(BaseSpec *anchor);

    using TypicalReaction::TypicalReaction;

    double rate() const { return 1e5; }
};

#endif // DIMERFORMATION_H
