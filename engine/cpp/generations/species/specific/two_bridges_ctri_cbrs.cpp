#include "two_bridges_ctri_cbrs.h"
#include "../../reactions/typical/two_bridges_to_high_bridge.h"

const ushort TwoBridgesCTRiCBRs::__indexes[1] = { 0 };
const ushort TwoBridgesCTRiCBRs::__roles[1] = { 5 };

void TwoBridgesCTRiCBRs::find(TwoBridges *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(5))
    {
        if (!anchor->hasRole(TWO_BRIDGES_CTRi_CBRs, 5))
        {
            create<TwoBridgesCTRiCBRs>(parent);
        }
    }
}

void TwoBridgesCTRiCBRs::findAllTypicalReactions()
{
    TwoBridgesToHighBridge::find(this);
}
