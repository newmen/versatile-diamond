#ifndef MIGRATION_DOWN_AT_DIMER_FROM_DIMER_H
#define MIGRATION_DOWN_AT_DIMER_FROM_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_dimer_cmsu.h"
#include "../typical.h"

class MigrationDownAtDimerFromDimer : public Typical<MIGRATION_DOWN_AT_DIMER_FROM_DIMER, 2>
{
public:
    static void find(DimerCRs *target);
    static void find(MethylOnDimerCMsu *target);

    MigrationDownAtDimerFromDimer(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e12; }
    void doIt();

    const std::string name() const override { return "migration down at activated dimer from methyl on dimer"; }
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_DIMER_H
