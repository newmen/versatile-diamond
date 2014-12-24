#ifndef MIGRATION_DOWN_AT_DIMER_FROM_111_H
#define MIGRATION_DOWN_AT_DIMER_FROM_111_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_111_cmsiu.h"
#include "../typical.h"

class MigrationDownAtDimerFrom111 : public Typical<MIGRATION_DOWN_AT_DIMER_FROM_111, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(DimerCRs *target);
    static void find(MethylOn111CMsiu *target);

    MigrationDownAtDimerFrom111(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_111_H
