#ifndef METHYL_ON_111_CMSU_H
#define METHYL_ON_111_CMSU_H

#include "../specific/methyl_on_111_cmu.h"
#include "../base_specific.h"

class MethylOn111CMsu :
        public BaseSpecific<DependentSpec<ParentSpec>, METHYL_ON_111_CMsu, 1>
{
public:
    static void find(MethylOn111CMu *parent);

    MethylOn111CMsu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_111(cm: *, cm: u)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_111_CMSU_H
