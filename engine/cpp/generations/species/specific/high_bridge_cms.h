#ifndef HIGH_BRIDGE_CMS_H
#define HIGH_BRIDGE_CMS_H

#include "high_bridge.h"

class HighBridgeCMs :
        public BaseSpecific<DependentSpec<BaseSpec>, HIGH_BRIDGE_CMs, 1>
{
public:
    static void find(HighBridge *parent);

    HighBridgeCMs(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "high_bridge(cm: *)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // HIGH_BRIDGE_CMS_H
