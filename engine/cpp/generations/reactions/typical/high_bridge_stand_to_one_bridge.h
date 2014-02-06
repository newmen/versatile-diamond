#ifndef HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
#define HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H

#include "../../species/specific/high_bridge.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../typical.h"

class HighBridgeStandToOneBridge : public Typical<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE, 2>
{
public:
    static constexpr double RATE = 6.1e13 * exp(-36.3e3 / (1.98 * Env::T));

    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);

    HighBridgeStandToOneBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
