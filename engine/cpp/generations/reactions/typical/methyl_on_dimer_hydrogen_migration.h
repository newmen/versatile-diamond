#ifndef METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
#define METHYL_ON_DIMER_HYDROGEN_MIGRATION_H

#include "../../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../../specific_specs/methyl_on_dimer_cls_cmu.h"

class MethylOnDimerHydrogenMigration : public MonoSpecReaction
{
public:
    static void find(MethylOnDimerCLsCMu *target);

//    using MonoSpecReaction::MonoSpecReaction;
    MethylOnDimerHydrogenMigration(SpecificSpec *target) : MonoSpecReaction(target) {}

    double rate() const { return 1e6; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "methyl on dimer hydrogen migration"; }
#endif // PRINT

protected:
    void remove() override;
};

#endif // METHYL_ON_DIMER_HYDROGEN_MIGRATION_H
