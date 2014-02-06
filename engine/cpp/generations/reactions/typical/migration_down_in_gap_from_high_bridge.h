#ifndef MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H
#define MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/high_bridge_cms.h"
#include "../typical.h"

class MigrationDownInGapFromHighBridge : public Typical<MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE, 3>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(BridgeCRs *target);
    static void find(HighBridgeCMs *target);

    MigrationDownInGapFromHighBridge(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H
