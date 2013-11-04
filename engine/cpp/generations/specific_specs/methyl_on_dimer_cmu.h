#ifndef METHYL_ON_DIMER_CMU_H
#define METHYL_ON_DIMER_CMU_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/methyl_on_dimer.h"

class MethylOnDimerCMu : public SpecificSpec
{
public:
    static void find(MethylOnDimer *parent);

//    using SpecificSpec::SpecificSpec;
    MethylOnDimerCMu(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: u)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // METHYL_ON_DIMER_CMU_H
