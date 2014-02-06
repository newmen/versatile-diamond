#ifndef MIGRATION_DOWN_IN_GAP_H
#define MIGRATION_DOWN_IN_GAP_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_bridge_cbi_cmssu.h"
#include "../typical.h"

class MigrationDownInGap : public Typical<MIGRATION_DOWN_IN_GAP, 3>
{
public:
    static constexpr double RATE = 5e12 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(BridgeCRs *target);
    static void find(MethylOnBridgeCBiCMssu *target);

    MigrationDownInGap(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // MIGRATION_DOWN_IN_GAP_H
