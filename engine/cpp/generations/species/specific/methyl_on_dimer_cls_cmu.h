#ifndef METHYL_ON_DIMER_CLS_CMU_H
#define METHYL_ON_DIMER_CLS_CMU_H

#include "../base_specific.h"
#include "methyl_on_dimer_cmu.h"

class MethylOnDimerCLsCMu : public BaseSpecific<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CLs_CMu, 1>
{
public:
    static void find(MethylOnDimerCMu *parent);

    MethylOnDimerCLsCMu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cl: *, cm: u)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CLS_CMU_H
