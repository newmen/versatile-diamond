#ifndef DIMER_FORMATION_NEAR_BRIDGE_H
#define DIMER_FORMATION_NEAR_BRIDGE_H

#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class DimerFormationNearBridge : public Typical<DIMER_FORMATION_NEAR_BRIDGE, 2>
{
public:
    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

    DimerFormationNearBridge(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 2.1e5; }
    void doIt();

    const std::string name() const override { return "dimer formation near bridge"; }
};

#endif // DIMER_FORMATION_NEAR_BRIDGE_H
