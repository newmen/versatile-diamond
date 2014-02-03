#ifndef HIGH_BRIDGE_TO_METHYL_H
#define HIGH_BRIDGE_TO_METHYL_H

#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/high_bridge.h"
#include "../typical.h"

class HighBridgeToMethyl : public Typical<HIGH_BRIDGE_TO_METHYL, 2>
{
public:
    static constexpr double RATE = 2.7e9 * exp(-2.9e3 / (1.98 * Env::T)); // REAL: A = 2.7e11

    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

    HighBridgeToMethyl(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "high bridge to methyl"; }

private:
    static void findByBridge(SpecificSpec *target);
};

#endif // HIGH_BRIDGE_TO_METHYL_H
