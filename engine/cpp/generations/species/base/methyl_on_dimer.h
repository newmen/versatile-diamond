#ifndef METHYL_ON_DIMER_H
#define METHYL_ON_DIMER_H

#include "../sidepiece/dimer.h"
#include "../base.h"

class MethylOnDimer :
        public Base<AdditionalAtomsWrapper<AtomShiftWrapper<DependentSpec<ParentSpec>>, 1>, METHYL_ON_DIMER, 2>
{
public:
    static void find(Dimer *target);

    MethylOnDimer(Atom *additionalAtom, ushort atomsShift, ParentSpec *parent) :
        Base(additionalAtom, atomsShift, parent) {}

    void store() override;
    void remove() override;

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
