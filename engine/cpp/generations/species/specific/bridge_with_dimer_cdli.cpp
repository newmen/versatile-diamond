#include "bridge_with_dimer_cdli.h"
#include "../../reactions/typical/dimer_drop_near_bridge.h"
#include "bridge_with_dimer_cbti_cbrs_cdli.h"

const ushort BridgeWithDimerCDLi::__indexes[1] = { 6 };
const ushort BridgeWithDimerCDLi::__roles[1] = { 20 };

void BridgeWithDimerCDLi::find(BridgeWithDimer *parent)
{
    Atom *anchor = parent->atom(6);
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

void BridgeWithDimerCDLi::findAllTypicalReactions()
{
    DimerDropNearBridge::find(this);
}
