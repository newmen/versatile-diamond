#ifndef DIMER_FORMATION_NEAR_BRIDGE_H
#define DIMER_FORMATION_NEAR_BRIDGE_H

#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../many_typical.h"

class DimerFormationNearBridge : public ManyTypical<DIMER_FORMATION_NEAR_BRIDGE, 2>
{
public:
    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

//    using ManyTypical::ManyTypical;
    DimerFormationNearBridge(SpecificSpec **targets) : ManyTypical(targets) {}

    double rate() const { return 2.1e5; }
    void doIt();

    std::string name() const override { return "dimer formation near bridge"; }
};

#endif // DIMER_FORMATION_NEAR_BRIDGE_H
