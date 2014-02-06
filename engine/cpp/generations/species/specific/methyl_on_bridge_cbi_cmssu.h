#ifndef METHYL_ON_BRIDGE_CBI_CMSSU_H
#define METHYL_ON_BRIDGE_CBI_CMSSU_H

#include "methyl_on_bridge_cbi_cmsu.h"

class MethylOnBridgeCBiCMssu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_BRIDGE_CBi_CMssu, 1>>
{
public:
    static void find(MethylOnBridgeCBiCMsu *parent);

    MethylOnBridgeCBiCMssu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT

protected:
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // METHYL_ON_BRIDGE_CBI_CMSSU_H
