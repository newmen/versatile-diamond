#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class DimerCRs : public Specific<AtomShiftWrapper<DependentSpec<BaseSpec>>, DIMER_CRs, 1>
{
public:
    static void find(Dimer *parent);

    DimerCRs(ushort atomsShift, ParentSpec *parent) : Specific(atomsShift, parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // DIMER_CRS_H
