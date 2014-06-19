#ifndef METHYL_ON_DIMER_CMSIU_H
#define METHYL_ON_DIMER_CMSIU_H

#include "methyl_on_dimer_cmiu.h"

class MethylOnDimerCMsiu :
        public Specific<Base<LocalableRole<DependentSpec<ParentSpec>, 0>, METHYL_ON_DIMER_CMsiu, 1>>
{
public:
    static void find(MethylOnDimerCMiu *parent);

    MethylOnDimerCMsiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

    void concretizeLocal(Atom *target) const override;
    void unconcretizeLocal(Atom *target) const override;

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMSIU_H
