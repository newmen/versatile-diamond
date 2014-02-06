#ifndef TWO_BRIDGES_TO_HIGH_BRIDGE_H
#define TWO_BRIDGES_TO_HIGH_BRIDGE_H

#include "../../species/specific/two_bridges_ctri_cbrs.h"
#include "../typical.h"

class TwoBridgesToHighBridge : public Typical<TWO_BRIDGES_TO_HIGH_BRIDGE>
{
public:
    static constexpr double RATE = 1.1e8 * exp(-3.2e3 / (1.98 * Env::T));

    static void find(TwoBridgesCTRiCBRs *target);

    TwoBridgesToHighBridge(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // TWO_BRIDGES_TO_HIGH_BRIDGE_H
