#ifndef HIGH_BRIDGE_TO_TWO_BRIDGES_H
#define HIGH_BRIDGE_TO_TWO_BRIDGES_H

#include "../../specific_specs/high_bridge.h"
#include "../../specific_specs/bridge_crs.h"
#include "../many_typical.h"

class HighBridgeToTwoBridges :
        public ManyTypical<HIGH_BRIDGE_STAND_TO_TWO_BRIDGES, SCA_HIGH_BRIDGE_STAND_TO_ONE_BRIDGE, 2>
{
public:
    static void find(HighBridge *target);
    static void find(BridgeCRs *target);

//    using ManyTypical::ManyTypical;
    HighBridgeToTwoBridges(SpecificSpec **targets) : ManyTypical(targets) {}

    double rate() const { return 7.7e6; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "high bridge incorporates in crystal lattice near another bridge"; }
#endif // PRINT
};

#endif // HIGH_BRIDGE_TO_TWO_BRIDGES_H
