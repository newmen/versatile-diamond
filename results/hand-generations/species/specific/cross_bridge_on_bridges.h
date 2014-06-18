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
    const char *name() const override;
#endif // PRINT

protected:
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // CROSS_BRIDGE_ON_BRIDGES_H
