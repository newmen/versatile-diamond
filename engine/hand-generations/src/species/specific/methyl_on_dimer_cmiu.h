#ifndef METHYL_ON_DIMER_CMIU_H
#define METHYL_ON_DIMER_CMIU_H

#include "../base/methyl_on_dimer.h"
#include "../specific.h"

class MethylOnDimerCMiu :
        public Specific<Base<LocalableRole<DependentSpec<ParentSpec>, 0>, METHYL_ON_DIMER_CMiu, 1>>
{
public:
    static void find(MethylOnDimer *parent);

    MethylOnDimerCMiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;

    void concretizeLocal(Atom *target) const override;
    void unconcretizeLocal(Atom *target) const override;
};

#endif // METHYL_ON_DIMER_CMIU_H
