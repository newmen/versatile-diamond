#ifndef MIGRATION_DOWN_IN_GAP_FROM_111_H
#define MIGRATION_DOWN_IN_GAP_FROM_111_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_111_cmssu.h"
#include "../typical.h"

class MigrationDownInGapFrom111 : public Typical<MIGRATION_DOWN_IN_GAP_FROM_111, 3>
{
public:
    static constexpr double RATE = 5e12 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(BridgeCRs *target);
    static void find(MethylOn111CMssu *target);

    MigrationDownInGapFrom111(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_111_H
