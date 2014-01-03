#ifndef MEHYL_ON_DIMER_DEACTIVATION_H
#define MEHYL_ON_DIMER_DEACTIVATION_H

#include "../../../species/base/methyl_on_dimer.h"
#include "../../local.h"
#include "../surface_deactivation.h"

class MethylOnDimerDeactivation :
        public Local<DeactivationData, SurfaceDeactivation, METHYL_ON_DIMER_DEACTIVATION, MethylOnDimer, 14>
{
    typedef Local<DeactivationData, SurfaceDeactivation, METHYL_ON_DIMER_DEACTIVATION, MethylOnDimer, 14> ParentType;

public:
    MethylOnDimerDeactivation(Atom *target) : Local(target) {}

    double rate() const { return 3670; }
    const std::string name() const { return "methyl on dimer deactivation"; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnDimerDeactivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnDimerDeactivation>(anchor); }
};

#endif // MEHYL_ON_DIMER_DEACTIVATION_H
