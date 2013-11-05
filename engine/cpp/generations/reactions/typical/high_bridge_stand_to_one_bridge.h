#ifndef HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
#define HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H

#include "../../../reactions/few_specs_reaction.h"
using namespace vd;

#include "../../specific_specs/high_bridge.h"

class HighBridgeStandToOneBridge : public FewSpecsReaction<2>
{
public:
    static void find(HighBridge *target);

//    using FewSpecsReaction::FewSpecsReaction;
    HighBridgeStandToOneBridge(SpecificSpec **targets) : FewSpecsReaction<2>(targets) {}

    double rate() const { return 5e6; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "high bridge stand to bridge at new level"; }
#endif // PRINT

protected:
    void remove() override;

private:
    static void checkAndAdd(HighBridge *target, Atom *neighbour);
};


#endif // HIGH_BRIDGE_STAND_TO_ONE_BRIDGE_H
