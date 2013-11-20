#ifndef METHYL_ON_DIMER_CMU_H
#define METHYL_ON_DIMER_CMU_H

#include "../specific.h"
#include "../base/methyl_on_dimer.h"

class MethylOnDimerCMu : public Specific<METHYL_ON_DIMER_CMu, 1>
{
public:
    static void find(MethylOnDimer *parent);

//    using Specific<METHYL_ON_DIMER_CMu, 1>::Specific;
    MethylOnDimerCMu(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: u)"; }
#endif // PRINT

    void findAllChildren() override;
    void findAllReactions() override {}

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMU_H
