#include "cross_bridge_on_bridges.h"
#include "../base/methyl_on_bridge.h"
#include "../../reactions/typical/sierpinski_drop.h"

#ifdef PRINT
const char *CrossBridgeOnBridges::name() const
{
    static const char value[] = "cross_bridge_on_briges";
    return value;
}
#endif // PRINT

void CrossBridgeOnBridges::find(Atom *anchor)
{
    if (anchor->is(10))
    {
        if (!anchor->checkAndFind(CROSS_BRIDGE_ON_BRIDGES, 10))
        {
            auto species = anchor->specsByRole<MethylOnBridge, 2>(14);
            if (species.all())
            {
                Atom *atoms[2] = { species[0]->atom(1), species[1]->atom(1) };
                eachNeighbour(atoms[0], &Diamond::cross_100, [&](Atom *neighbour) {
                    if (atoms[1] == neighbour)
                    {
                        ParentSpec *parents[2] = { species[0], species[1] };
                        create<CrossBridgeOnBridges>(parents);
                    }
                });
            }
        }
    }
}

void CrossBridgeOnBridges::findAllTypicalReactions()
{
    SierpinskiDrop::find(this);
}
