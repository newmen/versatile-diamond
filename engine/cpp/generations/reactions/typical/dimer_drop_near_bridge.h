#ifndef DIMER_DROP_NEAR_BRIDGE_H
#define DIMER_DROP_NEAR_BRIDGE_H

#include "../../species/specific/bridge_with_dimer_cdli.h"
#include "../typical.h"

class DimerDropNearBridge : public Typical<DIMER_DROP_NEAR_BRIDGE, 1>
{
public:
    static constexpr double RATE = 1.2e11 * exp(-4e3 / (1.98 * Env::T));

    static void find(BridgeWithDimerCDLi *target);

    DimerDropNearBridge(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // DIMER_DROP_NEAR_BRIDGE_H
