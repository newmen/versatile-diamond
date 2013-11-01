#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../../species/specific_spec.h"
#include "../../species/atom_shifter_wrapper.h"
using namespace vd;

#include "../base_specs/dimer.h"

class DimerCRs : public AtomShifterWrapper<SpecificSpec>
{
public:
    static void find(Dimer *target);

//    using AtomShifterWrapper<SpecificSpec>::AtomShifterWrapper;
    DimerCRs(ushort atomsShift, ushort type, BaseSpec *parent) :
        AtomShifterWrapper<SpecificSpec>(atomsShift, type, parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

    void findChildren() override;
};

#endif // DIMER_CRS_H
