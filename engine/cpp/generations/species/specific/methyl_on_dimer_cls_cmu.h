#ifndef METHYL_ON_DIMER_CLS_CMU_H
#define METHYL_ON_DIMER_CLS_CMU_H

#include "../specific.h"
#include "methyl_on_dimer_cmu.h"

class MethylOnDimerCLsCMu : public Specific<METHYL_ON_DIMER_CLs_CMu, 1>
{
public:
    static void find(MethylOnDimerCMu *parent);

//    using Specific::Specific;
    MethylOnDimerCLsCMu(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cl: *, cm: u)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CLS_CMU_H
