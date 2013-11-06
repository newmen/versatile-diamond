#ifndef METHYL_TO_HIGH_BRIDGE_H
#define METHYL_TO_HIGH_BRIDGE_H

#include "../../specific_specs/methyl_on_dimer_cmsu.h"
#include "../mono_typical.h"

class MethylToHighBridge : public MonoTypical<METHYL_TO_HIGH_BRIDGE>
{
public:
    static void find(MethylOnDimerCMsu *target);

//    using MonoTypical::MonoTypical;
    MethylToHighBridge(SpecificSpec *target) : MonoTypical(target) {}

    double rate() const { return 5e5; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "methyl to high bridge"; }
#endif // PRINT
};

#endif // METHYL_TO_HIGH_BRIDGE_H
