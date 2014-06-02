#ifndef METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
#define METHYL_ON_DIMER_HYDROGEN_MIGRATION_H

#include "../../species/specific/methyl_on_dimer_cls_cmhiu.h"
#include "../typical.h"

class MethylOnDimerHydrogenMigration : public Typical<METHYL_ON_DIMER_HYDROGEN_MIGRATION>
{
    static const char __name[];

public:
    static double RATE();

    static void find(MethylOnDimerCLsCMhiu *target);

    MethylOnDimerHydrogenMigration(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
