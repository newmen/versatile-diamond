#ifndef MIGRATION_DOWN_IN_GAP_FROM_111_H
#define MIGRATION_DOWN_IN_GAP_FROM_111_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_111_cmssu.h"
#include "../typical.h"

class MigrationDownInGapFrom111 : public Typical<MIGRATION_DOWN_IN_GAP_FROM_111, 3>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(BridgeCRs *target);
    static void find(MethylOn111CMssu *target);

    MigrationDownInGapFrom111(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_111_H
