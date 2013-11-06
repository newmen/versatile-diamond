#ifndef METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
#define METHYL_ON_DIMER_HYDROGEN_MIGRATION_H

#include "../../specific_specs/methyl_on_dimer_cls_cmu.h"
#include "../mono_typical.h"

class MethylOnDimerHydrogenMigration : public MonoTypical<METHYL_ON_DIMER_HYDROGEN_MIGRATION>
{
public:
    static void find(MethylOnDimerCLsCMu *target);

//    using MonoTypical::MonoTypical;
    MethylOnDimerHydrogenMigration(SpecificSpec *target) : MonoTypical(target) {}

    double rate() const { return 1e6; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "methyl on dimer hydrogen migration"; }
#endif // PRINT
};

#endif // METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
