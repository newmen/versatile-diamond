#ifndef DIMER_CRI_CLI_H
#define DIMER_CRI_CLI_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/dimer.h"

class DimerCRiCLi : public SpecificSpec
{
public:
    static void find(Dimer *parent);

//    using SpecificSpec::SpecificSpec;
    DimerCRiCLi(ushort type, BaseSpec *parent) : SpecificSpec(type, parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: i, cl: i)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // DIMER_CRI_CLI_H
