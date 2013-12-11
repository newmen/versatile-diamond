#include "bridge_ctsi.h"
#include "../../reactions/typical/dimer_formation.h"
#include "../../reactions/typical/dimer_formation_near_bridge.h"
#include "../../reactions/typical/high_bridge_stand_to_one_bridge.h"

ushort BridgeCTsi::__indexes[1] = { 0 };
ushort BridgeCTsi::__roles[1] = { 28 };

void BridgeCTsi::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(28))
    {
        if (!anchor->hasRole<BridgeCTsi>(28))
        {
            createBy<BridgeCTsi>(parent);
        }
    }
}

void BridgeCTsi::findAllReactions()
{
    DimerFormation::find(this);
    DimerFormationNearBridge::find(this);
    HighBridgeStandToOneBridge::find(this);
}
