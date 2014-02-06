#ifndef DIMER_FORMATION_NEAR_BRIDGE_H
#define DIMER_FORMATION_NEAR_BRIDGE_H

#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class DimerFormationNearBridge : public Typical<DIMER_FORMATION_NEAR_BRIDGE, 2>
{
public:
    static constexpr double RATE = 7.5e11 * exp(-4e3 / (1.98 * Env::T));

    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

    DimerFormationNearBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // DIMER_FORMATION_NEAR_BRIDGE_H
