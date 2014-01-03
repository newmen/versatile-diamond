#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../sidepiece/dimer.h"
#include "../base_specific.h"

class DimerCRs : public BaseSpecific<AtomShiftWrapper<DependentSpec<ParentSpec>>, DIMER_CRs, 1>
{
public:
    static void find(Dimer *parent);

    DimerCRs(ushort atomsShift, ParentSpec *parent) : BaseSpecific(atomsShift, parent) {}

#ifdef PRINT
    const std::string name() const override { return "dimer(cr: *)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // DIMER_CRS_H
