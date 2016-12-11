#ifndef ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H
#define ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H

#include "../base.h"
#include "../specific.h"

class OriginalCrossBridgeOnBridges : public Specific<Base<DependentSpec<ParentSpec, 2>, CROSS_BRIDGE_ON_BRIDGES, 3>>
{
public:
#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    OriginalCrossBridgeOnBridges(ParentSpec **parents) : Specific(parents) {}
};

#endif // ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H
