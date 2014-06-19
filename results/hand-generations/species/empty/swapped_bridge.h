#ifndef SWAPPED_BRIDGE_H
#define SWAPPED_BRIDGE_H

#include "../base/bridge.h"
#include "../empty.h"

class SwappedBridge : public Empty<AtomsSwapWrapper, SWAPPED_BRIDGE>
{
public:
    SwappedBridge(Bridge *parent) : Empty(1, 2, parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT
};

#endif // SWAPPED_BRIDGE_H
