#ifndef MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H
#define MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/high_bridge_cms.h"
#include "../typical.h"

class MigrationDownInGapFromHighBridge :
        public Typical<MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE, 3>
{
public:
    static void find(BridgeCRs *target);
    static void find(HighBridgeCMs *target);

    MigrationDownInGapFromHighBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e2; }
    void doIt();

    const std::string name() const override { return "migration down in gap from high bridge"; }
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE_H
