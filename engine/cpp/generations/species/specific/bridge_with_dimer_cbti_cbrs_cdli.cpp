#include "bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../../reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h"

const ushort BridgeWithDimerCBTiCBRsCDLi::__indexes[2] = { 0, 1 };
const ushort BridgeWithDimerCBTiCBRsCDLi::__roles[2] = { 0, 5 };

void BridgeWithDimerCBTiCBRsCDLi::find(BridgeWithDimerCDLi *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(0) && parent->atom(1)->is(5))
    {
        if (!anchor->hasRole<BridgeWithDimerCBTiCBRsCDLi>(5))
        {
            create<BridgeWithDimerCBTiCBRsCDLi>(parent);
        }
    }
}

void BridgeWithDimerCBTiCBRsCDLi::findAllReactions()
{
    BridgeWithDimerToHighBridgeAndDimer::find(this);
}
