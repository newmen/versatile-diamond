#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "typical_reaction.h"

class DimerFormation : TypicalReaction<2>
{
public:
    static void find(Atom *anchor);

    using TypicalReaction::TypicalReaction;

    double rate() const { return 8.9e11; }
};

#endif // DIMERFORMATION_H
