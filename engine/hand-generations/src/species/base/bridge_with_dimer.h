#ifndef BRIDGE_WITH_DIMER_H
#define BRIDGE_WITH_DIMER_H

#include "../base.h"

class BridgeWithDimer : public Base<DependentSpec<ParentSpec, 3>, BRIDGE_WITH_DIMER, 1>
{
public:
    static void find(Atom *anchor);

    BridgeWithDimer(ParentSpec **parents) : Base(parents) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
};

#endif // BRIDGE_WITH_DIMER_H
