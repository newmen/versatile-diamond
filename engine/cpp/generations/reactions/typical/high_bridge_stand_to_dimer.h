#ifndef HIGH_BRIDGE_STAND_TO_DIMER_H
#define HIGH_BRIDGE_STAND_TO_DIMER_H

#include "../../species/specific/high_bridge.h"
#include "../../species/specific/dimer_crs_cli.h"
#include "../typical.h"

class HighBridgeStandToDimer : public Typical<HIGH_BRIDGE_STAND_TO_DIMER, 2>
{
public:
    static void find(HighBridge *target);
    static void find(DimerCRsCLi *target);

    HighBridgeStandToDimer(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 1.219e6; }
    void doIt();

    const std::string name() const override { return "high bridge stand to dimer"; }
};

#endif // HIGH_BRIDGE_STAND_TO_DIMER_H
