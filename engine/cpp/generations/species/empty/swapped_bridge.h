#ifndef SWAPPED_BRIDGE_H
#define SWAPPED_BRIDGE_H

#include "../base/bridge.h"
#include "../empty.h"

class SwappedBridge : public Empty<AtomsSwapWrapper<DependentSpec<ParentSpec>>, SWAPPED_BRIDGE>
{
public:
    SwappedBridge(Bridge *parent) : Empty(1, 2, parent) {}

#ifdef PRINT
    std::string name() const override { return "swapped bridge"; }
#endif // PRINT
};

#endif // SWAPPED_BRIDGE_H
