#ifndef MIGRATION_DOWN_AT_DIMER_FROM_111_H
#define MIGRATION_DOWN_AT_DIMER_FROM_111_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_111_cmsu.h"
#include "../typical.h"

class MigrationDownAtDimerFrom111 : public Typical<MIGRATION_DOWN_AT_DIMER_FROM_111, 2>
{
public:
    static constexpr double RATE = 1e13 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(DimerCRs *target);
    static void find(MethylOn111CMsu *target);

    MigrationDownAtDimerFrom111(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // MIGRATION_DOWN_AT_DIMER_FROM_111_H
