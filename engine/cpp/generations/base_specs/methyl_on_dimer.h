#ifndef METHYL_ON_DIMER_H
#define METHYL_ON_DIMER_H

#include "../../species/atom_shifter_wrapper.h"
using namespace vd;

#include "dimer.h"

class MethylOnDimer : public AtomShifterWrapper<DependentSpec<1>>
{
public:
    static void find(BaseSpec *target);

//    using AtomShifterWrapper<DependentSpec<1>>::AtomShifterWrapper;
    MethylOnDimer(ushort type, BaseSpec **parents, ushort atomsShift) :
        AtomShifterWrapper<DependentSpec<1>>(type, parents, atomsShift) {}

#ifdef PRINT
    std::string name() const override { return "methyl on dimer"; }
#endif // PRINT

    void findChildren() override;

};

#endif // METHYL_ON_DIMER_H
