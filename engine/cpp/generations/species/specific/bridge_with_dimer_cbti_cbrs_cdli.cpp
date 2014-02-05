#include "bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../../reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h"

const ushort BridgeWithDimerCBTiCBRsCDLi::__indexes[2] = { 3, 4 };
const ushort BridgeWithDimerCBTiCBRsCDLi::__roles[2] = { 0, 5 };

void BridgeWithDimerCBTiCBRsCDLi::find(BridgeWithDimerCDLi *parent)
{
    Atom *anchor = parent->atom(3);
    if (anchor->is(0) && parent->atom(4)->is(5))
    {
        if (!anchor->hasRole<BridgeWithDimerCBTiCBRsCDLi>(0))
        {
            create<BridgeWithDimerCBTiCBRsCDLi>(parent);
        }
    }
}

void BridgeWithDimerCBTiCBRsCDLi::findAllTypicalReactions()
{
    BridgeWithDimerToHighBridgeAndDimer::find(this);
}
