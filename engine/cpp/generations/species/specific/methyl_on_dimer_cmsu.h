#ifndef METHYL_ON_DIMER_CMSU_H
#define METHYL_ON_DIMER_CMSU_H

#include "../specific.h"
#include "methyl_on_dimer_cmu.h"

class MethylOnDimerCMsu : public Specific<METHYL_ON_DIMER_CMsu, 1>
{
public:
    static void find(MethylOnDimerCMu *parent);

//    using Specific::Specific;
    MethylOnDimerCMsu(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: *, cm: u)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMSU_H
