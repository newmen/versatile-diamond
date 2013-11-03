#ifndef METHYL_ON_DIMER_CLS_H
#define METHYL_ON_DIMER_CLS_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/methyl_on_dimer.h"

class MethylOnDimerCLs : public SpecificSpec
{
public:
    static void find(MethylOnDimer *parent);

//    using SpecificSpec::SpecificSpec;
    MethylOnDimerCLs(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cl: *)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // METHYL_ON_DIMER_CLS_H
