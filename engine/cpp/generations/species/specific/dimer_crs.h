#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class DimerCRs : public Specific<Base<AtomShiftWrapper<DependentSpec<ParentSpec>>, DIMER_CRs, 1>>
{
public:
    static void find(Dimer *parent);

    DimerCRs(ushort atomsShift, ParentSpec *parent) : Specific(atomsShift, parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // DIMER_CRS_H
