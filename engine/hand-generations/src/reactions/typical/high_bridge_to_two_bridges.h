#ifndef HIGH_BRIDGE_TO_TWO_BRIDGES_H
#define HIGH_BRIDGE_TO_TWO_BRIDGES_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/high_bridge.h"
#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class HighBridgeToTwoBridges : public Typical<HIGH_BRIDGE_STAND_TO_TWO_BRIDGES, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(HighBridge *target);
    static void find(BridgeCRs *target);

    HighBridgeToTwoBridges(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // HIGH_BRIDGE_TO_TWO_BRIDGES_H
