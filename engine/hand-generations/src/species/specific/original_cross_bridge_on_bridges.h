#ifndef ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H
#define ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H

#include "../base.h"
#include "../specific.h"

class OriginalCrossBridgeOnBridges : public Specific<Base<DependentSpec<ParentSpec, 2>, CROSS_BRIDGE_ON_BRIDGES, 3>>
{
public:
#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    OriginalCrossBridgeOnBridges(ParentSpec **parents) : Specific(parents) {}
};

#endif // ORIGINAL_CROSS_BRIDGE_ON_BRIDGES_H
