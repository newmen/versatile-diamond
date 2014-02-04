#ifndef METHYL_ON_DIMER_CMSU_H
#define METHYL_ON_DIMER_CMSU_H

#include "methyl_on_dimer_cmu.h"

class MethylOnDimerCMsu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_DIMER_CMsu, 1>>
{
public:
    static void find(MethylOnDimerCMu *parent);

    MethylOnDimerCMsu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_dimer(cm: *, cm: u)"; }
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

#endif // METHYL_ON_DIMER_CMSU_H
