#ifndef MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H
#define MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/high_bridge.h"
#include "../typical.h"

class MigrationDownAtDimerFromHighBridge : public Typical<MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE, 2>
{
    static const char __name[];

public:
    static double RATE();

    static void find(DimerCRs *target);
    static void find(HighBridge *target);

    MigrationDownAtDimerFromHighBridge(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE_H
