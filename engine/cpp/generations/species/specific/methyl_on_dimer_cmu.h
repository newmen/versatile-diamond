#ifndef METHYL_ON_DIMER_CMU_H
#define METHYL_ON_DIMER_CMU_H

#include "../base/methyl_on_dimer.h"
#include "../specific.h"

class MethylOnDimerCMu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_DIMER_CMu, 1>>
{
public:
    static void find(MethylOnDimer *parent);

    MethylOnDimerCMu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: u)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMU_H
