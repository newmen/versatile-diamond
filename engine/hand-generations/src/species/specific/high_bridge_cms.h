#ifndef HIGH_BRIDGE_CMS_H
#define HIGH_BRIDGE_CMS_H

#include "high_bridge.h"

class HighBridgeCMs : public Specific<Base<DependentSpec<BaseSpec>, HIGH_BRIDGE_CMs, 1>>
{
public:
    static void find(HighBridge *parent);

    HighBridgeCMs(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllTypicalReactions() final;
};

#endif // HIGH_BRIDGE_CMS_H
