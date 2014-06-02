#ifndef BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H
#define BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H

#include "../../species/specific/bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../typical.h"

class BridgeWithDimerToHighBridgeAndDimer : public Typical<BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER, 1>
{
    static const char __name[];

public:
    static double RATE();

    static void find(BridgeWithDimerCBTiCBRsCDLi *target);

    BridgeWithDimerToHighBridgeAndDimer(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H
