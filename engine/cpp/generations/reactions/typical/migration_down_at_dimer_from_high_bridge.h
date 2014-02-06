#ifndef MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H
#define MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/high_bridge.h"
#include "../typical.h"

class MigrationDownAtDimerFromHighBridge :
        public Typical<MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE, 2>
{
public:
    static constexpr double RATE = 5e10 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(DimerCRs *target);
    static void find(HighBridge *target);

    MigrationDownAtDimerFromHighBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H
