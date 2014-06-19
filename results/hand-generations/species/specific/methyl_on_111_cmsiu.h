#ifndef METHYL_ON_111_CMSIU_H
#define METHYL_ON_111_CMSIU_H

#include "methyl_on_111_cmiu.h"

class MethylOn111CMsiu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_111_CMsiu, 1>>
{
public:
    static void find(MethylOn111CMiu *parent);

    MethylOn111CMsiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
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

#endif // METHYL_ON_111_CMSIU_H
