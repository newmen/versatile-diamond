#ifndef MIGRATION_DOWN_IN_GAP_FROM_DIMER_H
#define MIGRATION_DOWN_IN_GAP_FROM_DIMER_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_dimer_cmssiu.h"
#include "../typical.h"

class MigrationDownInGapFromDimer : public Typical<MIGRATION_DOWN_IN_GAP_FROM_DIMER, 3>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(BridgeCRs *target);
    static void find(MethylOnDimerCMssiu *target);

    MigrationDownInGapFromDimer(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_DIMER_H
