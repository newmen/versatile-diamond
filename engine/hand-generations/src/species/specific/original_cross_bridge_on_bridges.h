#ifndef ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H
#define ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H

#include "../base.h"
#include "../specific.h"

class OriginalCrossBridgeOnBridges : public Specific<Base<DependentSpec<ParentSpec, 2>, CROSS_BRIDGE_ON_BRIDGES, 3>>
{
public:
#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    OriginalCrossBridgeOnBridges(ParentSpec **parents) : Specific(parents) {}
};

#endif // ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H
