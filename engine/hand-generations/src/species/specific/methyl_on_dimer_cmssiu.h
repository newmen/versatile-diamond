#ifndef METHYL_ON_DIMER_CMSSIU_H
#define METHYL_ON_DIMER_CMSSIU_H

#include "methyl_on_dimer_cmsiu.h"

class MethylOnDimerCMssiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CMssiu, 1>>
{
public:
    static void find(MethylOnDimerCMsiu *parent);

    MethylOnDimerCMssiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_DIMER_CMSSIU_H
