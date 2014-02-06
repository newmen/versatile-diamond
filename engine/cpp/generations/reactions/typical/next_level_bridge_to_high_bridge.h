#ifndef NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE_H
#define NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE_H

#include "../../species/specific/bridge_crs_cti_cli.h"
#include "../typical.h"

class NextLevelBridgeToHighBridge : public Typical<NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE>
{
public:
    static constexpr double RATE = 1.1e12 * exp(-12.3e3 / (1.98 * Env::T));

    static void find(BridgeCRsCTiCLi *target);

    NextLevelBridgeToHighBridge(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE_H
