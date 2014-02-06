#ifndef MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H
#define MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/high_bridge_cms.h"
#include "../typical.h"

class MigrationDownInGapFromHighBridge :
        public Typical<MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE, 3>
{
public:
    static constexpr double RATE = 1e9 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(BridgeCRs *target);
    static void find(HighBridgeCMs *target);

    MigrationDownInGapFromHighBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H
