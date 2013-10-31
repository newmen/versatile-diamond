#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../../species/specific_spec.h"
using namespace vd;

class DimerCRs : public SpecificSpec
{
public:
    static void find(BaseSpec *parent);

//    using SpecificSpec::SpecificSpec;
    DimerCRs(ushort type, BaseSpec *parent);

#ifdef PRINT
    std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // DIMER_CRS_H
