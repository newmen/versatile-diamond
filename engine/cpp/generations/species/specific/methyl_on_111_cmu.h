#ifndef METHYL_ON_111_CMU_H
#define METHYL_ON_111_CMU_H

#include "../base/methyl_on_bridge.h"
#include "../base_specific.h"

class MethylOn111CMu :
        public BaseSpecific<DependentSpec<ParentSpec>, METHYL_ON_111_CMu, 2>
{
public:
    static void find(MethylOnBridge *parent);

    MethylOn111CMu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "methyl_on_111(cm: u)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // METHYL_ON_111_CMU_H
