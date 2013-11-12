#include "bridge_ctsi.h"
#include "../../reactions/typical/dimer_formation.h"
#include "../../reactions/typical/high_bridge_stand_to_one_bridge.h"

ushort BridgeCTsi::__indexes[1] = { 0 };
ushort BridgeCTsi::__roles[1] = { 28 };

void BridgeCTsi::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(28))
    {
        if (!anchor->hasRole(28, BRIDGE_CTsi))
        {
            auto spec = new BridgeCTsi(parent);
            spec->store();
        }
    }
}

void BridgeCTsi::findChildren()
{
    DimerFormation::find(this);
    HighBridgeStandToOneBridge::find(this);
}
