#ifndef METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
#define METHYL_ON_DIMER_HYDROGEN_MIGRATION_H

#include "../../species/specific/methyl_on_dimer_cls_cmu.h"
#include "../typical.h"

class MethylOnDimerHydrogenMigration : public Typical<METHYL_ON_DIMER_HYDROGEN_MIGRATION>
{
public:
    static void find(MethylOnDimerCLsCMu *target);

    MethylOnDimerHydrogenMigration(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 1e6; }
    void doIt();

    const std::string name() const override { return "methyl on dimer hydrogen migration"; }
};

#endif // METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
