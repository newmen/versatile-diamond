#ifndef BRIDGE_WITH_DIMER_H
#define BRIDGE_WITH_DIMER_H

#include "../base/bridge.h"
#include "../empty_dependent.h"

class BridgeWithDimer : public AtomsSwapWrapper<EmptyDependent<ParentSpec, BRIDGE_WITH_DIMER, 3>>
{
public:
    static void find(Bridge *parent);

    BridgeWithDimer(ushort from, ushort to, ParentSpec **parents) :
        AtomsSwapWrapper(from, to, parents) {}

#ifdef PRINT
    std::string name() const override { return "bridge with dimer"; }
#endif // PRINT

protected:
    void findAllChildren() override;
};

#endif // BRIDGE_WITH_DIMER_H
