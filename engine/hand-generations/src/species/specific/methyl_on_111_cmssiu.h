#ifndef METHYL_ON_111_CMSSIU_H
#define METHYL_ON_111_CMSSIU_H

#include "methyl_on_111_cmsiu.h"

class MethylOn111CMssiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_111_CMssiu, 1>>
{
public:
    static void find(MethylOn111CMsiu *parent);

    MethylOn111CMssiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_111_CMSSIU_H
