#ifndef METHYL_ON_DIMER_H
#define METHYL_ON_DIMER_H

#include "../../../species/atom_shift_wrapper.h"
#include "../../../species/additional_atoms_wrapper.h"
#include "../lateral/dimer.h"
#include "../dependent.h"

class MethylOnDimer : public Dependent<METHYL_ON_DIMER, 2, AdditionalAtomsWrapper<AtomShiftWrapper<DependentSpec<1>>, 1>>
{
public:
    static void find(Dimer *target);

    MethylOnDimer(Atom **additionalAtoms, ushort atomsShift, BaseSpec *parent) :
        Dependent(additionalAtoms, atomsShift, &parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl on dimer"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // METHYL_ON_DIMER_H
