#ifndef METHYL_ON_BRIDGE_CBI_CMSSU_H
#define METHYL_ON_BRIDGE_CBI_CMSSU_H

#include "../specific/methyl_on_bridge_cbi_cmsu.h"
#include "../base_specific.h"

class MethylOnBridgeCBiCMssu :
        public BaseSpecific<DependentSpec<BaseSpec>, METHYL_ON_BRIDGE_CBi_CMssu, 1>
{
public:
    static void find(MethylOnBridgeCBiCMsu *parent);

    MethylOnBridgeCBiCMssu(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "methyl_on_bridge(cb: i, cm: **, cm: u)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_BRIDGE_CBI_CMSSU_H
