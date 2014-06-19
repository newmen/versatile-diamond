#ifndef METHYL_ON_BRIDGE_CBI_CMSIU_H
#define METHYL_ON_BRIDGE_CBI_CMSIU_H

#include "methyl_on_bridge_cbi_cmiu.h"

class MethylOnBridgeCBiCMsiu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_BRIDGE_CBi_CMsiu, 1>>
{
public:
    static void find(MethylOnBridgeCBiCMiu *parent);

    MethylOnBridgeCBiCMsiu(ParentSpec *parent) : Specific(parent) {}

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

#endif // METHYL_ON_BRIDGE_CBI_CMSIU_H
