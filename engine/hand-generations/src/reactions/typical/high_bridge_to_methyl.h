#ifndef HIGH_BRIDGE_TO_METHYL_H
#define HIGH_BRIDGE_TO_METHYL_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/high_bridge.h"
#include "../typical.h"

class HighBridgeToMethyl : public Typical<HIGH_BRIDGE_TO_METHYL, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(HighBridge *target);
    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

    HighBridgeToMethyl(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

private:
    static void findByBridge(SpecificSpec *target, ushort anchorIndex);
};

#endif // HIGH_BRIDGE_TO_METHYL_H
