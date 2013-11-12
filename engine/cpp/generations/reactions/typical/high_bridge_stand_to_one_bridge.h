#ifndef HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
#define HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H

#include "../../species/specific/high_bridge.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../many_typical.h"

class HighBridgeStandToOneBridge : public ManyTypical<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE, 2>
{
public:
    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);

//    using ManyTypical::ManyTypical;
    HighBridgeStandToOneBridge(SpecificSpec **targets) : ManyTypical(targets) {}

    double rate() const { return 5e6; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "high bridge stand to bridge at new level"; }
#endif // PRINT
};

#endif // HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
