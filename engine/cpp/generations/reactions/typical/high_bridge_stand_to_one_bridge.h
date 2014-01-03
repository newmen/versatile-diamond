#ifndef HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
#define HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H

#include "../../species/specific/high_bridge.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../typical.h"

class HighBridgeStandToOneBridge : public Typical<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE, 2>
{
public:
    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);

    HighBridgeStandToOneBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e6; }
    void doIt();

    const std::string name() const override { return "high bridge stand to bridge at new level"; }
};

#endif // HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
