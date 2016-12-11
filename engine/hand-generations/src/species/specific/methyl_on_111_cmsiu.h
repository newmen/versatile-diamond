#ifndef METHYL_ON_111_CMSIU_H
#define METHYL_ON_111_CMSIU_H

#include "methyl_on_111_cmiu.h"

class MethylOn111CMsiu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_111_CMsiu, 1>>
{
public:
    static void find(MethylOn111CMiu *parent);

    MethylOn111CMsiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_111_CMSIU_H
