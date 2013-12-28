#include "high_bridge.h"
#include "../../reactions/typical/high_bridge_stand_to_one_bridge.h"
#include "../../reactions/typical/high_bridge_to_two_bridges.h"

ushort HighBridge::__indexes[2] = { 1, 0 };
ushort HighBridge::__roles[2] = { 19, 18 };

void HighBridge::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(19))
    {
        if (!anchor->hasRole<HighBridge>(19))
        {
            Atom *amorph = anchor->amorphNeighbour();
            if (amorph->is(18))
            {
                create<HighBridge>(amorph, parent);
            }
        }
    }
}

void HighBridge::findAllReactions()
{
    HighBridgeStandToOneBridge::find(this);
    HighBridgeToTwoBridges::find(this);
}
