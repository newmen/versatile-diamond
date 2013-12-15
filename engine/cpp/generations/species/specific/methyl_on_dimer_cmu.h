#ifndef METHYL_ON_DIMER_CMU_H
#define METHYL_ON_DIMER_CMU_H

#include "../base/methyl_on_dimer.h"
#include "../base.h"

class MethylOnDimerCMu : public Base<DependentSpec<ParentSpec>, METHYL_ON_DIMER_CMu, 1>
{
public:
    static void find(MethylOnDimer *parent);

    MethylOnDimerCMu(ParentSpec *parent) : Base(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: u)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMU_H
