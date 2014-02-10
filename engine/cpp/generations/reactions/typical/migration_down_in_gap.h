#ifndef MIGRATION_DOWN_IN_GAP_H
#define MIGRATION_DOWN_IN_GAP_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_bridge_cbi_cmssiu.h"
#include "../typical.h"

class MigrationDownInGap : public Typical<MIGRATION_DOWN_IN_GAP, 3>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(BridgeCRs *target);
    static void find(MethylOnBridgeCBiCMssiu *target);

    MigrationDownInGap(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_IN_GAP_H
