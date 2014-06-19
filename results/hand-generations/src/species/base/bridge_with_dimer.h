#ifndef BRIDGE_WITH_DIMER_H
#define BRIDGE_WITH_DIMER_H

#include "../base.h"

class BridgeWithDimer : public Base<DependentSpec<ParentSpec, 3>, BRIDGE_WITH_DIMER, 1>
{
public:
    static void find(Atom *anchor);

    BridgeWithDimer(ParentSpec **parents) : Base(parents) {}

#ifdef PRINT
    const char *name() const override;
#endif // PRINT

protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // BRIDGE_WITH_DIMER_H
