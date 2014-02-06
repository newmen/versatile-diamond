#ifndef METHYL_ON_DIMER_CMSSU_H
#define METHYL_ON_DIMER_CMSSU_H

#include "methyl_on_dimer_cmsu.h"

class MethylOnDimerCMssu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CMssu, 1>>
{
public:
    static void find(MethylOnDimerCMsu *parent);

    MethylOnDimerCMssu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT

protected:
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMSSU_H
