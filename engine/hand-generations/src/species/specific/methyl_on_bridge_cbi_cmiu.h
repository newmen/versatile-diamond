#ifndef METHYL_ON_BRIDGE_CBI_CMIU_H
#define METHYL_ON_BRIDGE_CBI_CMIU_H

#include "../base/methyl_on_bridge.h"
#include "../specific.h"

class MethylOnBridgeCBiCMiu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_BRIDGE_CBi_CMiu, 2>>
{
public:
    static void find(MethylOnBridge *parent);

    MethylOnBridgeCBiCMiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // METHYL_ON_BRIDGE_CBI_CMIU_H
