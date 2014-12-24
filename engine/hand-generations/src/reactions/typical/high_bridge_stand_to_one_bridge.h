#ifndef HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
#define HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/high_bridge.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../typical.h"

class HighBridgeStandToOneBridge : public Typical<HIGH_BRIDGE_STAND_TO_ONE_BRIDGE, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);

    HighBridgeStandToOneBridge(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
