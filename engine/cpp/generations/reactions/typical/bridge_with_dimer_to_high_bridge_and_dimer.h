#ifndef BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H
#define BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H

#include "../../species/specific/bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../typical.h"

class BridgeWithDimerToHighBridgeAndDimer :
        public Typical<BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER, 1>
{
public:
    static void find(BridgeWithDimerCBTiCBRsCDLi *target);

    BridgeWithDimerToHighBridgeAndDimer(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 3.78e3; }
    void doIt();

    const std::string name() const override { return "bridge with dimer to high bridge and dimer"; }
};

#endif // BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H
