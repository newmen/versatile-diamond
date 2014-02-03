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
    static constexpr double RATE = Env::cH * 2.8e8 * pow(Env::T, 3.5) * exp(-37.5e3 / (1.98 * Env::T));

    MethylOnBridgeActivation(Atom *target) : Local(target) {}

    double rate() const override { return RATE; }
    std::string name() const override { return "methyl on surface activation"; }

    static void concretize(Atom *anchor) { ParentType::concretize<MethylOnBridgeActivation>(anchor); }
    static void unconcretize(Atom *anchor) { ParentType::unconcretize<MethylOnBridgeActivation>(anchor); }
};

#endif // METHYL_ON_BRIDGE_ACTIVATION_H
