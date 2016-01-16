#include "two_bridges_ctri_cbrs.h"
#include "../../reactions/typical/two_bridges_to_high_bridge.h"

template <> const ushort TwoBridgesCTRiCBRs::Base::__indexes[2] = { 0, 3 };
template <> const ushort TwoBridgesCTRiCBRs::Base::__roles[2] = { 5, 0 };

#ifdef PRINT
const char *TwoBridgesCTRiCBRs::name() const
{
    static const char value[] = "two_bridges(ctr: i, cbr: *)";
    return value;
}
#endif // PRINT

void TwoBridgesCTRiCBRs::find(TwoBridges *parent)
{
    Atom *anchors[2];
    for (int i = 0; i < 2; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(5) && anchors[1]->is(0))
    {
        if (!anchors[0]->hasRole(TWO_BRIDGES_CTRi_CBRs, 5) || !anchors[1]->hasRole(TWO_BRIDGES_CTRi_CBRs, 0))
        {
            create<TwoBridgesCTRiCBRs>(parent);
        }
    }
}

void TwoBridgesCTRiCBRs::findAllTypicalReactions()
{
    TwoBridgesToHighBridge::find(this);
}
