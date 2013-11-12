#include "bridge_crs.h"
#include "../../reactions/typical/next_level_bridge_to_high_bridge.h"
#include "../../reactions/typical/high_bridge_to_two_bridges.h"

ushort BridgeCRs::__indexes[1] = { 1 };
ushort BridgeCRs::__roles[1] = { 5 };

void BridgeCRs::find(Bridge *parent)
{
    uint checkingIndexes[2] = { 1, 2 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(checkingIndexes[i]);
        if (anchor->isVisited()) continue; // because no children species

        if (anchor->is(5))
        {
            if (!anchor->hasRole(5, BRIDGE_CRs))
            {
                auto spec = new BridgeCRs(checkingIndexes[i], 1, parent);
                spec->store();
            }
        }
    }
}

void BridgeCRs::findChildren()
{
//    NextLevelBridgeToHighBridge::find(this);
    HighBridgeToTwoBridges::find(this);
}
