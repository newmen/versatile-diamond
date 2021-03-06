#ifndef BRIDGE_WITH_DIMER_H
#define BRIDGE_WITH_DIMER_H

#include "../base.h"

class BridgeWithDimer : public Base<DependentSpec<ParentSpec, 3>, BRIDGE_WITH_DIMER, 2>
{
public:
    static void find(Atom *anchor);

    BridgeWithDimer(ParentSpec **parents) : Base(parents) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllChildren() final;
};

#endif // BRIDGE_WITH_DIMER_H
