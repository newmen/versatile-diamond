#ifndef METHYL_ON_DIMER_H
#define METHYL_ON_DIMER_H

#include "../../species/atom_shift_wrapper.h"
#include "../../species/additional_atoms_wrapper.h"
using namespace vd;

#include "dimer.h"

class MethylOnDimer : public AdditionalAtomsWrapper<AtomShiftWrapper<DependentSpec<1>>, 1>
{
public:
    static void find(Dimer *target);

//    using AdditionalAtomsWrapper<AtomShiftWrapper<DependentSpec<1>>, 1>::AdditionalAtomsWrapper;
    MethylOnDimer(Atom **additionalAtoms, ushort atomsShift, ushort type, BaseSpec **parents) :
        AdditionalAtomsWrapper<AtomShiftWrapper<DependentSpec<1>>, 1>(additionalAtoms, atomsShift, type, parents) {}

#ifdef PRINT
    std::string name() const override { return "methyl on dimer"; }
#endif // PRINT

    void findChildren() override;

};

#endif // METHYL_ON_DIMER_H
