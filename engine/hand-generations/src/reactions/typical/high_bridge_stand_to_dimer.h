#ifndef HIGH_BRIDGE_STAND_TO_DIMER_H
#define HIGH_BRIDGE_STAND_TO_DIMER_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/high_bridge.h"
#include "../../species/specific/dimer_crs_cli.h"
#include "../typical.h"

class HighBridgeStandToDimer : public Typical<HIGH_BRIDGE_STAND_TO_DIMER, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(HighBridge *target);
    static void find(DimerCRsCLi *target);

    HighBridgeStandToDimer(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    void changeAtoms(Atom **atoms) final;
};

#endif // HIGH_BRIDGE_STAND_TO_DIMER_H
