#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "../base_specs/dimer.h"

// TODO: maybe need shifted spec?
class DimerCRs : public SpecificSpec
{
    ushort _atomsShift;

public:
    static void find(Dimer *parent);

//    using SpecificSpec::SpecificSpec;
    DimerCRs(ushort type, BaseSpec *parent, ushort atomsShift) : SpecificSpec(type, parent), _atomsShift(atomsShift) {}

    Atom *atom(ushort index);

#ifdef PRINT
    std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // DIMER_CRS_H
