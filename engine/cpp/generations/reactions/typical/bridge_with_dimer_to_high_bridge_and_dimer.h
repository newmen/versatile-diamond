#ifndef BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H
#define BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H

#include "../../species/specific/bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../typical.h"

class BridgeWithDimerToHighBridgeAndDimer :
        public Typical<BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER, 1>
{
public:
    static constexpr double RATE = 4.2e8 * exp(-14.9e3 / (1.98 * Env::T));

    static void find(BridgeWithDimerCBTiCBRsCDLi *target);

    BridgeWithDimerToHighBridgeAndDimer(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER_H
