#ifndef METHYL_ON_DIMER_ACTIVATION_H
#define METHYL_ON_DIMER_ACTIVATION_H

#include "../../../species/base/methyl_on_dimer.h"
#include "../../local.h"
#include "../surface_activation.h"

class MethylOnDimerActivation :
        public Local<ActivationData, SurfaceActivation, METHYL_ON_DIMER_ACTIVATION, MethylOnDimer, 14>
{
public:
    MethylOnDimerActivation(Atom *target) : Local(target) {}

    double rate() const { return 38950; }
    std::string name() const { return "methyl on dimer activation"; }
};

#endif // METHYL_ON_DIMER_ACTIVATION_H
