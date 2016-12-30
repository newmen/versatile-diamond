#ifndef METHYL_ON_BRIDGE_CBI_CMSSIU_H
#define METHYL_ON_BRIDGE_CBI_CMSSIU_H

#include "methyl_on_bridge_cbi_cmsiu.h"

class MethylOnBridgeCBiCMssiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_BRIDGE_CBi_CMssiu, 1>>
{
public:
    static void find(MethylOnBridgeCBiCMsiu *parent);

    MethylOnBridgeCBiCMssiu(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || SERIALIZE

protected:
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_BRIDGE_CBI_CMSSIU_H
