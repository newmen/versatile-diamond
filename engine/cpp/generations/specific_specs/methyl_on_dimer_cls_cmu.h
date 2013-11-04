#ifndef METHYL_ON_DIMER_CLS_CMU_H
#define METHYL_ON_DIMER_CLS_CMU_H

#include "methyl_on_dimer_cmu.h"

class MethylOnDimerCLsCMu : public SpecificSpec
{
public:
    static void find(MethylOnDimerCMu *parent);

//    using SpecificSpec::SpecificSpec;
    MethylOnDimerCLsCMu(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cl: *, cm: u)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // METHYL_ON_DIMER_CLS_CMU_H
