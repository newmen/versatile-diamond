#ifndef BRIDGE_WITH_DIMER_H
#define BRIDGE_WITH_DIMER_H

#include "../empty.h"
#include "bridge.h"

class BridgeWithDimer : public Empty<AtomsSwapWrapper<DependentSpec<ParentSpec, 3>>, BRIDGE_WITH_DIMER>
{
public:
    static void find(Bridge *parent);

    BridgeWithDimer(ushort from, ushort to, ParentSpec **parents) : Empty(from, to, parents) {}

#ifdef PRINT
    std::string name() const override { return "bridge with dimer"; }
#endif // PRINT

protected:
    void findAllChildren() override;
};

#endif // BRIDGE_WITH_DIMER_H
