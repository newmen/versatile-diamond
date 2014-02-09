#ifndef MIGRATION_DOWN_AT_DIMER_H
#define MIGRATION_DOWN_AT_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_bridge_cbi_cmsiu.h"
#include "../typical.h"

class MigrationDownAtDimer : public Typical<MIGRATION_DOWN_AT_DIMER, 2>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(DimerCRs *target);
    static void find(MethylOnBridgeCBiCMsiu *target);

    MigrationDownAtDimer(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_AT_DIMER_H
