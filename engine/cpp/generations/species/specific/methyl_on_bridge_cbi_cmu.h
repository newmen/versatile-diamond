#ifndef METHYL_ON_BRIDGE_CBI_CMU_H
#define METHYL_ON_BRIDGE_CBI_CMU_H

#include "../base/methyl_on_bridge.h"
#include "../specific.h"

class MethylOnBridgeCBiCMu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_BRIDGE_CBi_CMu, 2>>
{
public:
    static void find(MethylOnBridge *parent);

    MethylOnBridgeCBiCMu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_bridge(cb: i, cm: u)"; }
#endif // PRINT

protected:
    void findAllChildren() override;
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // METHYL_ON_BRIDGE_CBI_CMU_H
