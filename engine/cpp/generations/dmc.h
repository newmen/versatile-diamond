#ifndef DMC_H
#define DMC_H

#include "../mc/mc.h"
using namespace vd;

#include "reactions/ubiquitous/reaction_activation.h"
#include "reactions/ubiquitous/reaction_deactivation.h"
#include "reactions/typical/dimer_formation.h"

class DMC : public MC
{
    MultiEventsContainer<ReactionActivation> _activations;
    MultiEventsContainer<ReactionDeactivation> _deactivations;

    EventsContainer<DimerFormation> _dimerFormations;

public:
    void addActivations(ReactionActivation *reaction, uint n) { addUb(&_activations, reaction, n); }
    void removeActivations(ReactionActivation *reaction, uint n)  { removeUb(&_activations, reaction, n); }

    void addDeactivations(ReactionDeactivation *reaction, uint n) { addUb(&_deactivations, reaction, n); }
    void removeDeactivations(ReactionDeactivation *reaction, uint n)  { removeUb(&_deactivations, reaction, n); }

    void addDimerFormation(DimerFormation *reaction) { add(&_dimerFormations, reaction); }
    void removeDimerFormation(DimerFormation *reaction)  { remove(&_dimerFormations, reaction); }
};

#endif // DMC_H
