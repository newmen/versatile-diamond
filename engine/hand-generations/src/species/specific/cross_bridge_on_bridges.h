#ifndef CROSS_BRIDGE_ON_BRIDGES_H
#define CROSS_BRIDGE_ON_BRIDGES_H

#include "../base.h"
#include "../specific.h"

class CrossBridgeOnBridges : public Specific<Base<DependentSpec<BaseSpec, 2>, CROSS_BRIDGE_ON_BRIDGES, 1>>
{
public:
    static void find(Atom *anchor);

    CrossBridgeOnBridges(ParentSpec **parents) : Specific(parents) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // CROSS_BRIDGE_ON_BRIDGES_H
