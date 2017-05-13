#ifndef METHYL_ON_BRIDGE_CBS_CMSIU_H
#define METHYL_ON_BRIDGE_CBS_CMSIU_H

#include "methyl_on_bridge_cbi_cmsiu.h"

class MethylOnBridgeCBsCMsiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_BRIDGE_CBs_CMsiu, 1>>
{
public:
    static void find(MethylOnBridgeCBiCMsiu *parent);

    MethylOnBridgeCBsCMsiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_BRIDGE_CBS_CMSIU_H
