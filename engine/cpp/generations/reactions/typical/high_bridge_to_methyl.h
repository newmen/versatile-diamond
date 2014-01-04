#ifndef HIGH_BRIDGE_TO_METHYL_H
#define HIGH_BRIDGE_TO_METHYL_H

#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/high_bridge.h"
#include "../typical.h"

class HighBridgeToMethyl : public Typical<HIGH_BRIDGE_TO_METHYL, 2>
{
public:
    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

    HighBridgeToMethyl(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 6.275e10; }
    void doIt();

    const std::string name() const override { return "high bridge to methyl"; }

private:
    static void findByBridge(SpecificSpec *target);
};

#endif // HIGH_BRIDGE_TO_METHYL_H
