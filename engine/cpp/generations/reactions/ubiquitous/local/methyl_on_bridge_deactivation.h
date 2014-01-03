#ifndef MEHYL_ON_BRIDGE_DEACTIVATION_H
#define MEHYL_ON_BRIDGE_DEACTIVATION_H

#include "../../../species/base/methyl_on_bridge.h"
#include "../../local.h"
#include "../surface_deactivation.h"

class MethylOnBridgeDeactivation :
        public Local<DeactivationData, SurfaceDeactivation, METHYL_ON_BRIDGE_DEACTIVATION, MethylOnBridge, 14>
{
    typedef Local<DeactivationData, SurfaceDeactivation, METHYL_ON_BRIDGE_DEACTIVATION, MethylOnBridge, 14> ParentType;

public:
    MethylOnBridgeDeactivation(Atom *target) : Local(target) {}

    double rate() const { return 3670; }
    const std::string name() const { return "methyl on dimer deactivation"; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnBridgeDeactivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnBridgeDeactivation>(anchor); }
};

#endif // MEHYL_ON_BRIDGE_DEACTIVATION_H
