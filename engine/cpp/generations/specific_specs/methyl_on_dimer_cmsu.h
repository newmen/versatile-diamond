#ifndef METHYL_ON_DIMER_CMSU_H
#define METHYL_ON_DIMER_CMSU_H

#include "methyl_on_dimer_cmu.h"

class MethylOnDimerCMsu : public SpecificSpec
{
public:
    static void find(MethylOnDimerCMu *parent);

//    using SpecificSpec::SpecificSpec;
    MethylOnDimerCMsu(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: *, cm: u)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // METHYL_ON_DIMER_CMSU_H
