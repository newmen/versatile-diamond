#ifndef HIGH_BRIDGE_TO_TWO_BRIDGES_H
#define HIGH_BRIDGE_TO_TWO_BRIDGES_H

#include "../../species/specific/high_bridge.h"
#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class HighBridgeToTwoBridges : public Typical<HIGH_BRIDGE_STAND_TO_TWO_BRIDGES, 2>
{
public:
    static constexpr double RATE = 2.9e11 * exp(-3.2e3 / (1.98 * Env::T));

    static void find(HighBridge *target);
    static void find(BridgeCRs *target);

    HighBridgeToTwoBridges(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "high bridge incorporates in crystal lattice near another bridge"; }
};

#endif // HIGH_BRIDGE_TO_TWO_BRIDGES_H
