#ifndef MEHYL_ON_DIMER_DEACTIVATION_H
#define MEHYL_ON_DIMER_DEACTIVATION_H

#include "../../local.h"
#include "../surface_deactivation.h"

class MethylOnDimerDeactivation :
        public Local<DeactivationData, SurfaceDeactivation, METHYL_ON_DIMER_DEACTIVATION, METHYL_ON_DIMER_CMsiu, 26>
{
    typedef Local<DeactivationData, SurfaceDeactivation, METHYL_ON_DIMER_DEACTIVATION, METHYL_ON_DIMER_CMsiu, 26> ParentType;

    static const char __name[];

public:
    static double RATE();

    MethylOnDimerDeactivation(Atom *target) : Local(target) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnDimerDeactivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnDimerDeactivation>(anchor); }
};

#endif // MEHYL_ON_DIMER_DEACTIVATION_H
