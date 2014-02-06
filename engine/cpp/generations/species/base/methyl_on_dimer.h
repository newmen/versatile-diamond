#ifndef METHYL_ON_DIMER_H
#define METHYL_ON_DIMER_H

#include "../sidepiece/dimer.h"
#include "../base.h"

class MethylOnDimer : public Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec>, 1>, METHYL_ON_DIMER, 2>
{
public:
    static void find(Dimer *target);

    MethylOnDimer(Atom *additionalAtom, ParentSpec *parent) : Base(additionalAtom, parent) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT

protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // METHYL_ON_DIMER_H
