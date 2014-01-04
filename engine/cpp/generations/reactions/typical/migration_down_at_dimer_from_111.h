#ifndef MIGRATION_DOWN_AT_DIMER_FROM_111_H
#define MIGRATION_DOWN_AT_DIMER_FROM_111_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_111_cmsu.h"
#include "../typical.h"

class MigrationDownAtDimerFrom111 : public Typical<MIGRATION_DOWN_AT_DIMER_FROM_111, 2>
{
public:
    static void find(DimerCRs *target);
    static void find(MethylOn111CMsu *target);

    MigrationDownAtDimerFrom111(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 5e6; }
    void doIt();

    const std::string name() const override { return "migration down at activated dimer from 111"; }
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_111_H
