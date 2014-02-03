#ifndef MIGRATION_DOWN_IN_GAP_FROM_DIMER_H
#define MIGRATION_DOWN_IN_GAP_FROM_DIMER_H

#include "../../species/specific/bridge_crs.h"
#include "../../species/specific/methyl_on_dimer_cmssu.h"
#include "../typical.h"

class MigrationDownInGapFromDimer : public Typical<MIGRATION_DOWN_IN_GAP_FROM_DIMER, 3>
{
public:
    static constexpr double RATE = 5e12 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(BridgeCRs *target);
    static void find(MethylOnDimerCMssu *target);

    MigrationDownInGapFromDimer(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "migration down in gap from methyl on dimer"; }
};

#endif // MIGRATION_DOWN_IN_GAP_FROM_DIMER_H
