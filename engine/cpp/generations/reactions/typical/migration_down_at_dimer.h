#ifndef MIGRATION_DOWN_AT_DIMER_H
#define MIGRATION_DOWN_AT_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_bridge_cbi_cmsu.h"
#include "../typical.h"

class MigrationDownAtDimer : public Typical<MIGRATION_DOWN_AT_DIMER, 2>
{
public:
    static void find(DimerCRs *target);
    static void find(MethylOnBridgeCBiCMsu *target);

    MigrationDownAtDimer(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e12; }
    void doIt();

    const std::string name() const override { return "migration down at activated dimer from methyl on bridge"; }
};

#endif // MIGRATION_DOWN_AT_DIMER_H
