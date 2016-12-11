#ifndef SYMMETRIC_CROSS_BRIDGE_ON_BRIDGES_H
#define SYMMETRIC_CROSS_BRIDGE_ON_BRIDGES_H

#include "../specific/original_cross_bridge_on_bridges.h"
#include "../empty_specific.h"

class SymmetricCrossBridgeOnBridges :
    public ParentsSwapWrapper<EmptySpecific<CROSS_BRIDGE_ON_BRIDGES>, OriginalCrossBridgeOnBridges, 0, 1>
{
public:
    SymmetricCrossBridgeOnBridges(OriginalCrossBridgeOnBridges *parent) : ParentsSwapWrapper(parent) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE
};

#endif // SYMMETRIC_CROSS_BRIDGE_ON_BRIDGES_H
