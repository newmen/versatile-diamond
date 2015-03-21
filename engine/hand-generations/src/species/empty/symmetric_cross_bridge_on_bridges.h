#ifndef SYMMETRIC_CROSS_BRIDGE_ON_BRIDGES_H
#define SYMMETRIC_CROSS_BRIDGE_ON_BRIDGES_H

#include "../specific/original_cross_bridge_on_bridges.h"
#include "../empty_specific.h"

class SymmetricCrossBridgeOnBridges :
    public ParentsSwapWrapper<EmptySpecific<CROSS_BRIDGE_ON_BRIDGES>, OriginalCrossBridgeOnBridges, 0, 1>
{
public:
    SymmetricCrossBridgeOnBridges(OriginalCrossBridgeOnBridges *parent) : ParentsSwapWrapper(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT
};

#endif // SYMMETRIC_CROSS_BRIDGE_ON_BRIDGES_H
