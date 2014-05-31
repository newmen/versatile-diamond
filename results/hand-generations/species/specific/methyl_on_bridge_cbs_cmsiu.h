#ifndef METHYL_ON_BRIDGE_CBS_CMSIU_H
#define METHYL_ON_BRIDGE_CBS_CMSIU_H

#include "methyl_on_bridge_cbi_cmsiu.h"

class MethylOnBridgeCBsCMsiu : public Specific<Base<DependentSpec<BaseSpec>, METHYL_ON_BRIDGE_CBs_CMsiu, 1>>
{
public:
    static void find(MethylOnBridgeCBiCMsiu *parent);

    MethylOnBridgeCBsCMsiu(ParentSpec *parent) : Specific(parent) {}

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

#endif // METHYL_ON_BRIDGE_CBS_CMSIU_H
