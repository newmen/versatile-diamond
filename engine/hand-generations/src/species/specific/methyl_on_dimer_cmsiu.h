#ifndef METHYL_ON_DIMER_CMSIU_H
#define METHYL_ON_DIMER_CMSIU_H

#include "methyl_on_dimer_cmiu.h"

class MethylOnDimerCMsiu :
        public Specific<Base<LocalableRole<DependentSpec<ParentSpec>, 0>, METHYL_ON_DIMER_CMsiu, 1>>
{
public:
    static void find(MethylOnDimerCMiu *parent);

    MethylOnDimerCMsiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || SERIALIZE

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;

    void concretizeLocal(Atom *target) const final;
    void unconcretizeLocal(Atom *target) const final;
};

#endif // METHYL_ON_DIMER_CMSIU_H
