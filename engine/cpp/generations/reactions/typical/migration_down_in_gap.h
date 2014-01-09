#ifndef MIGRATION_DOWN_IN_GAP_H
#define MIGRATION_DOWN_IN_GAP_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_bridge_cbi_cmssu.h"
#include "../typical.h"

class MigrationDownInGap : public Typical<MIGRATION_DOWN_IN_GAP, 3>
{
public:
    static void find(BridgeCRs *target);
    static void find(MethylOnBridgeCBiCMssu *target);

    MigrationDownInGap(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e8; }
    void doIt();

    const std::string name() const override { return "migration down in gap from methyl on bridge"; }
};

#endif // MIGRATION_DOWN_IN_GAP_H
