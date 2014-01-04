#ifndef MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H
#define MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/high_bridge.h"
#include "../typical.h"

class MigrationDownAtDimerFromHighBridge :
        public Typical<MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE, 2>
{
public:
    static void find(DimerCRs *target);
    static void find(HighBridge *target);

    MigrationDownAtDimerFromHighBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e2; }
    void doIt();

    const std::string name() const override { return "migration down at activated dimer from high bridge"; }
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H
