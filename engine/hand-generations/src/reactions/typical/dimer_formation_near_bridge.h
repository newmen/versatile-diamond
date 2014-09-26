#ifndef DIMER_FORMATION_NEAR_BRIDGE_H
#define DIMER_FORMATION_NEAR_BRIDGE_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class DimerFormationNearBridge : public Typical<DIMER_FORMATION_NEAR_BRIDGE, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(BridgeCTsi *target);
    static void find(BridgeCRs *target);

    DimerFormationNearBridge(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    void changeAtoms(Atom **atoms) final;
};

#endif // DIMER_FORMATION_NEAR_BRIDGE_H
