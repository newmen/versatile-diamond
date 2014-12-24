#ifndef CROSS_BRIDGE_ON_BRIDGES_H
#define CROSS_BRIDGE_ON_BRIDGES_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../empty/symmetric_cross_bridge_on_bridges.h"
#include "original_cross_bridge_on_bridges.h"

class CrossBridgeOnBridges :
    public Symmetric<OriginalCrossBridgeOnBridges, SymmetricCrossBridgeOnBridges>, public DiamondAtomsIterator
{
public:
    static void find(Atom *anchor);

    CrossBridgeOnBridges(ParentSpec **parents) : Symmetric(parents) {}

protected:
    void findAllChildren() final {}
    void findAllTypicalReactions() final;
};

#endif // CROSS_BRIDGE_ON_BRIDGES_H
