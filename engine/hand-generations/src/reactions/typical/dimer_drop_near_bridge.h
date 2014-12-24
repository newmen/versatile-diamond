#ifndef DIMER_DROP_NEAR_BRIDGE_H
#define DIMER_DROP_NEAR_BRIDGE_H

#include "../../species/specific/bridge_with_dimer_cdli.h"
#include "../typical.h"

class DimerDropNearBridge : public Typical<DIMER_DROP_NEAR_BRIDGE, 1>
{
    static const char __name[];

public:
    static double RATE();

    static void find(BridgeWithDimerCDLi *target);

    DimerDropNearBridge(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // DIMER_DROP_NEAR_BRIDGE_H
