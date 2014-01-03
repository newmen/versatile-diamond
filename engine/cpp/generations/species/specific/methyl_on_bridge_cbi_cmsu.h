#ifndef METHYL_ON_BRIDGE_CBI_CMSU_H
#define METHYL_ON_BRIDGE_CBI_CMSU_H

#include "../specific/methyl_on_bridge_cbi_cmu.h"
#include "../base_specific.h"

class MethylOnBridgeCBiCMsu :
        public BaseSpecific<DependentSpec<ParentSpec>, METHYL_ON_BRIDGE_CBi_CMsu, 1>
{
public:
    static void find(MethylOnBridgeCBiCMu *parent);

    MethylOnBridgeCBiCMsu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "methyl_on_bridge(cb: i, cm: *, cm: u)"; }
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

#endif // METHYL_ON_BRIDGE_CBI_CMSU_H
