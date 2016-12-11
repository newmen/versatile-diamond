#ifndef METHYL_ON_DIMER_CLS_CMHIU_H
#define METHYL_ON_DIMER_CLS_CMHIU_H

#include "methyl_on_dimer_cmiu.h"

class MethylOnDimerCLsCMhiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CLs_CMhiu, 2>>
{
public:
    static void find(MethylOnDimerCMiu *parent);

    MethylOnDimerCLsCMhiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_DIMER_CLS_CMHIU_H
