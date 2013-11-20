#ifndef METHYL_ON_BRIDGE_CBI_CMU_H
#define METHYL_ON_BRIDGE_CBI_CMU_H

#include "../specific.h"
#include "../base/methyl_on_bridge.h"

class MethylOnBridgeCBiCMu : public Specific<METHYL_ON_BRIDGE_CBi_CMu, 2>
{
public:
    static void find(MethylOnBridge *parent);

//    using Specific<METHYL_ON_BRIDGE_CBi_CMu, 2>::Specific;
    MethylOnBridgeCBiCMu(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_bridge(cb: i, cm: u)"; }
#endif // PRINT

    void findAllReactions() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // METHYL_ON_BRIDGE_CBI_CMU_H
