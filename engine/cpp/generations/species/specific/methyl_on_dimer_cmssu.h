#ifndef METHYL_ON_DIMER_CMSSU_H
#define METHYL_ON_DIMER_CMSSU_H

#include "../base_specific.h"
#include "methyl_on_dimer_cmsu.h"

class MethylOnDimerCMssu : public BaseSpecific<DependentSpec<BaseSpec>, METHYL_ON_DIMER_CMssu, 1>
{
public:
    static void find(MethylOnDimerCMsu *parent);

    MethylOnDimerCMssu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "methyl_on_dimer(cm: **, cm: u)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_DIMER_CMSSU_H