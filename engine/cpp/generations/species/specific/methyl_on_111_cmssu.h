#ifndef METHYL_ON_111_CMSSU_H
#define METHYL_ON_111_CMSSU_H

#include "../specific/methyl_on_111_cmsu.h"
#include "../base_specific.h"

class MethylOn111CMssu :
        public BaseSpecific<DependentSpec<BaseSpec>, METHYL_ON_111_CMssu, 1>
{
public:
    static void find(MethylOn111CMsu *parent);

    MethylOn111CMssu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "methyl_on_111(cm: **, cm: u)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_111_CMSSU_H
