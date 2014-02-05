#ifndef BRIDGE_WITH_DIMER_H
#define BRIDGE_WITH_DIMER_H

#include "../empty.h"

class BridgeWithDimer : public Empty<DependentSpec<ParentSpec, 3>, BRIDGE_WITH_DIMER>
{
public:
    static void find(Atom *anchor);

    BridgeWithDimer(ParentSpec **parents) : Empty(parents) {}

#ifdef PRINT
    std::string name() const override { return "bridge with dimer"; }
#endif // PRINT

protected:
    void findAllChildren() override;
};

#endif // BRIDGE_WITH_DIMER_H
