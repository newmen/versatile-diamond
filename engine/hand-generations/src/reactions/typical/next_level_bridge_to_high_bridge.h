#ifndef NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE_H
#define NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE_H

#include "../../species/specific/bridge_crs_cti_cli.h"
#include "../typical.h"

class NextLevelBridgeToHighBridge : public Typical<NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE>
{
    static const char __name[];

public:
    static double RATE();

    static void find(BridgeCRsCTiCLi *target);

    NextLevelBridgeToHighBridge(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    void changeAtoms(Atom **atoms) final;
};

#endif // NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE_H
