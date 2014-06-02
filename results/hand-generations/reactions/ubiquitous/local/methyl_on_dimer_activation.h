#ifndef METHYL_ON_DIMER_ACTIVATION_H
#define METHYL_ON_DIMER_ACTIVATION_H

#include "../../local.h"
#include "../surface_activation.h"

class MethylOnDimerActivation :
        public Local<ActivationData, SurfaceActivation, METHYL_ON_DIMER_ACTIVATION, METHYL_ON_DIMER, 14>
{
    typedef Local<ActivationData, SurfaceActivation, METHYL_ON_DIMER_ACTIVATION, METHYL_ON_DIMER, 14> ParentType;

    static const char __name[];

public:
    static double RATE();

    MethylOnDimerActivation(Atom *target) : Local(target) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnDimerActivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnDimerActivation>(anchor); }
};

#endif // METHYL_ON_DIMER_ACTIVATION_H
