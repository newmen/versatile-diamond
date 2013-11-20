#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../../../species/atom_shift_wrapper.h"
#include "../specific.h"
#include "../base/dimer.h"

class DimerCRs : public Specific<DIMER_CRs, 1, AtomShiftWrapper<SpecificSpec>>
{
public:
    static void find(Dimer *parent);

//    using Specific<DIMER_CRs, 1, AtomShiftWrapper<SpecificSpec>>::Specific;
    DimerCRs(ushort atomsShift, BaseSpec *parent) : Specific(atomsShift, parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

    void findAllReactions() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // DIMER_CRS_H
