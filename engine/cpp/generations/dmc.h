#ifndef DMC_H
#define DMC_H

#include "../mc/mc.h"
#include "reactions/ubiquitous/reaction_activation.h"
using namespace vd;

class DMC : public MC
{
    MultiEventsContainer<ReactionActivation> _activations;
//    MultiEventsContainer<ReactionDeactivation> _deactivations;

public:
    void addActivations(ReactionActivation *reaction, uint n) { addUb(&_activations, reaction, n); }
    void removeActivations(ReactionActivation *reaction, uint n)  { removeUb(&_activations, reaction, n); }
};

#endif // DMC_H
