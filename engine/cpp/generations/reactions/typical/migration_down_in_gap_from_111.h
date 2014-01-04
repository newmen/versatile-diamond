#ifndef MIGRATION_DOWN_IN_GAP_FROM_111_H
#define MIGRATION_DOWN_IN_GAP_FROM_111_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_111_cmssu.h"
#include "../typical.h"

class MigrationDownInGapFrom111 : public Typical<MIGRATION_DOWN_IN_GAP_FROM_111, 3>
{
public:
    static void find(BridgeCRs *target);
    static void find(MethylOn111CMssu *target);

    MigrationDownInGapFrom111(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e6; }
    void doIt();

    const std::string name() const override { return "migration down in gap from 111"; }
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_111_H
