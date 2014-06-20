#ifndef TWO_BRIDGES_TO_HIGH_BRIDGE_H
#define TWO_BRIDGES_TO_HIGH_BRIDGE_H

#include "../../species/specific/two_bridges_ctri_cbrs.h"
#include "../typical.h"

class TwoBridgesToHighBridge : public Typical<TWO_BRIDGES_TO_HIGH_BRIDGE>
{
    static const char __name[];

public:
    static double RATE();

    static void find(TwoBridgesCTRiCBRs *target);

    TwoBridgesToHighBridge(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // TWO_BRIDGES_TO_HIGH_BRIDGE_H
