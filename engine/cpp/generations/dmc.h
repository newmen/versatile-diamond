#ifndef DMC_H
#define DMC_H

#include "../mc/mc.h"
using namespace vd;

#include "reactions/ubiquitous/reaction_activation.h"
#include "reactions/ubiquitous/reaction_deactivation.h"

class DMC : public MC
{
    MultiEventsContainer<ReactionActivation> _activations;
    MultiEventsContainer<ReactionDeactivation> _deactivations;

public:
    void addActivations(ReactionActivation *reaction, uint n) { addUb(&_activations, reaction, n); }
    void removeActivations(ReactionActivation *reaction, uint n)  { removeUb(&_activations, reaction, n); }

    void addDeactivations(ReactionDeactivation *reaction, uint n) { addUb(&_deactivations, reaction, n); }
    void removeDeactivations(ReactionDeactivation *reaction, uint n)  { removeUb(&_deactivations, reaction, n); }
};

#endif // DMC_H
