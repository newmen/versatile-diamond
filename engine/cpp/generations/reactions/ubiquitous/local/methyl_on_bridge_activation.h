#ifndef METHYL_ON_BRIDGE_ACTIVATION_H
#define METHYL_ON_BRIDGE_ACTIVATION_H

#include "../../../species/base/methyl_on_bridge.h"
#include "../../local.h"
#include "../surface_activation.h"

class MethylOnBridgeActivation :
        public Local<ActivationData, SurfaceActivation, METHYL_ON_BRIDGE_ACTIVATION, MethylOnBridge, 14>
{
    typedef Local<ActivationData, SurfaceActivation, METHYL_ON_BRIDGE_ACTIVATION, MethylOnBridge, 14> ParentType;

public:
    MethylOnBridgeActivation(Atom *target) : Local(target) {}

    double rate() const { return 2.482e3; }
    const std::string name() const { return "methyl on surface activation"; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnBridgeActivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnBridgeActivation>(anchor); }
};

#endif // METHYL_ON_BRIDGE_ACTIVATION_H
