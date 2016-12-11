#ifndef METHYL_ON_BRIDGE_CBI_CMSIU_H
#define METHYL_ON_BRIDGE_CBI_CMSIU_H

#include "methyl_on_bridge_cbi_cmiu.h"

class MethylOnBridgeCBiCMsiu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_BRIDGE_CBi_CMsiu, 1>>
{
public:
    static void find(MethylOnBridgeCBiCMiu *parent);

    MethylOnBridgeCBiCMsiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_BRIDGE_CBI_CMSIU_H
