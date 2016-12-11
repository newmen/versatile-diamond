#ifndef METHYL_ON_DIMER_CMSSIU_H
#define METHYL_ON_DIMER_CMSSIU_H

#include "methyl_on_dimer_cmsiu.h"

class MethylOnDimerCMssiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CMssiu, 1>>
{
public:
    static void find(MethylOnDimerCMsiu *parent);

    MethylOnDimerCMssiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_DIMER_CMSSIU_H
