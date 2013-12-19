#ifndef METHYL_ON_DIMER_ACTIVATION_H
#define METHYL_ON_DIMER_ACTIVATION_H

#include "../../../species/base/methyl_on_dimer.h"
#include "../../local.h"
#include "../surface_activation.h"

class MethylOnDimerActivation :
        public Local<ActivationData, SurfaceActivation, METHYL_ON_DIMER_ACTIVATION, MethylOnDimer, 14>
{
    typedef Local<ActivationData, SurfaceActivation, METHYL_ON_DIMER_ACTIVATION, MethylOnDimer, 14> ParentType;

public:
    MethylOnDimerActivation(Atom *target) : Local(target) {}

    double rate() const { return 38950; }
    std::string name() const { return "methyl on dimer activation"; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnDimerActivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnDimerActivation>(anchor); }
};

#endif // METHYL_ON_DIMER_ACTIVATION_H
