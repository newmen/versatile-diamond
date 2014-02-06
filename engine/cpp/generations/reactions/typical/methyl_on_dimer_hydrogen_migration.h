#ifndef METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
#define METHYL_ON_DIMER_HYDROGEN_MIGRATION_H

#include "../../species/specific/methyl_on_dimer_cls_cmu.h"
#include "../typical.h"

class MethylOnDimerHydrogenMigration : public Typical<METHYL_ON_DIMER_HYDROGEN_MIGRATION>
{
public:
    static constexpr double RATE = 2.1e12 * exp(-37.5e3 / (1.98 * Env::T));

    static void find(MethylOnDimerCLsCMu *target);

    MethylOnDimerHydrogenMigration(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
