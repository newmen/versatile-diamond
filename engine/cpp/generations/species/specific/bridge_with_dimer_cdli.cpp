#include "bridge_with_dimer_cdli.h"
#include "../../reactions/typical/dimer_drop_near_bridge.h"
#include "bridge_with_dimer_cbti_cbrs_cdli.h"

const ushort BridgeWithDimerCDLi::__indexes[1] = { 9 };
const ushort BridgeWithDimerCDLi::__roles[1] = { 20 };

void BridgeWithDimerCDLi::find(BridgeWithDimer *parent)
{
    Atom *anchor = parent->atom(9);
    assert(anchor->is(22));

    if (anchor->is(20))
    {
        create<BridgeWithDimerCDLi>(parent);
    }
}

void BridgeWithDimerCDLi::findAllChildren()
{
    BridgeWithDimerCBTiCBRsCDLi::find(this);
}

void BridgeWithDimerCDLi::findAllReactions()
{
    DimerDropNearBridge::find(this);
}
