#ifndef METHYL_ON_111_CMSSIU_H
#define METHYL_ON_111_CMSSIU_H

#include "methyl_on_111_cmsiu.h"

class MethylOn111CMssiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_111_CMssiu, 1>>
{
public:
    static void find(MethylOn111CMsiu *parent);

    MethylOn111CMssiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_111_CMSSIU_H
