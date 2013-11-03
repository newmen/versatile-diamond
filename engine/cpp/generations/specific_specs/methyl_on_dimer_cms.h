#ifndef METHYL_ON_DIMER_CMS_H
#define METHYL_ON_DIMER_CMS_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/methyl_on_dimer.h"

class MethylOnDimerCMs : public SpecificSpec
{
public:
    static void find(MethylOnDimer *parent);

//    using SpecificSpec::SpecificSpec;
    MethylOnDimerCMs(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: *)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // METHYL_ON_DIMER_CMS_H
