#ifndef REACTION_ACTIVATION_H
#define REACTION_ACTIVATION_H

#include "../../../atom.h"
#include "../../../reaction.h"
using namespace vd;

class ReactionActivation : public Reaction
{
    Atom *_target;

public:
    ReactionActivation(Atom *target);

    double rate() const { return 3600; }
    void doIt();
};

#endif // REACTION_ACTIVATION_H
