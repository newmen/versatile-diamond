#include "methyl_on_bridge.h"
#include "../specific/methyl_on_bridge_cbi_cmu.h"

ushort MethylOnBridge::__indexes[2] = { 1, 0 };
ushort MethylOnBridge::__roles[2] = { 9, 14 };

void MethylOnBridge::find(Bridge *target)
{
    Atom *anchor = target->atom(0);

    if (anchor->is(9))
    {
        if (!checkAndFind(anchor, 9, METHYL_ON_BRIDGE))
        {
            Atom *methyl = anchor->amorphNeighbour();

            if (methyl->is(14))
            {
                BaseSpec *parent = target;
                auto spec = new MethylOnBridge(&methyl, &parent);
                spec->store();
            }
        }
    }
}

void MethylOnBridge::findAllChildren()
{
    MethylOnBridgeCBiCMu::find(this);
}
