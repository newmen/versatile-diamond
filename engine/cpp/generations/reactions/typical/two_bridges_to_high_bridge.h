#ifndef TWO_BRIDGES_TO_HIGH_BRIDGE_H
#define TWO_BRIDGES_TO_HIGH_BRIDGE_H

#include "../../species/specific/two_bridges_cbrs.h"
#include "../typical.h"

class TwoBridgesToHighBridge : public Typical<TWO_BRIDGES_TO_HIGH_BRIDGE>
{
public:
    static void find(TwoBridgesCBRs *target);

    TwoBridgesToHighBridge(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 2.198e7; }
    void doIt();

    const std::string name() const override { return "two bridges to high bridge"; }
};

#endif // TWO_BRIDGES_TO_HIGH_BRIDGE_H
