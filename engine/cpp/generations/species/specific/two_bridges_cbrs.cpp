#include "two_bridges_cbrs.h"
#include "../../reactions/typical/two_bridges_to_high_bridge.h"

const ushort TwoBridgesCBRs::__indexes[1] = { 1 };
const ushort TwoBridgesCBRs::__roles[1] = { 5 };

void TwoBridgesCBRs::find(TwoBridges *parent)
{
    Atom *anchor = parent->atom(1);
    if (anchor->is(5))
    {
        if (!anchor->hasRole<TwoBridgesCBRs>(5))
        {
            create<TwoBridgesCBRs>(parent);
        }
    }
}

void TwoBridgesCBRs::findAllReactions()
{
    TwoBridgesToHighBridge::find(this);
}
