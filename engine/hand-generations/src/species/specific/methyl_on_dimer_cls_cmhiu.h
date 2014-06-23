#ifndef METHYL_ON_DIMER_CLS_CMHIU_H
#define METHYL_ON_DIMER_CLS_CMHIU_H

#include "methyl_on_dimer_cmiu.h"

class MethylOnDimerCLsCMhiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CLs_CMhiu, 2>>
{
public:
    static void find(MethylOnDimerCMiu *parent);

    MethylOnDimerCLsCMhiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // METHYL_ON_DIMER_CLS_CMHIU_H
