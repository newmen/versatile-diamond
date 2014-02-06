#ifndef HIGH_BRIDGE_STAND_TO_DIMER_H
#define HIGH_BRIDGE_STAND_TO_DIMER_H

#include "../../species/specific/high_bridge.h"
#include "../../species/specific/dimer_crs_cli.h"
#include "../typical.h"

class HighBridgeStandToDimer : public Typical<HIGH_BRIDGE_STAND_TO_DIMER, 2>
{
public:
    static constexpr double RATE = 2.2e9 * exp(-14.9e3 / (1.98 * Env::T));

    static void find(HighBridge *target);
    static void find(DimerCRsCLi *target);

    HighBridgeStandToDimer(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // HIGH_BRIDGE_STAND_TO_DIMER_H
