#include "bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../../reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h"

template <> const ushort BridgeWithDimerCBTiCBRsCDLi::Base::__indexes[2] = { 0, 3 };
template <> const ushort BridgeWithDimerCBTiCBRsCDLi::Base::__roles[2] = { 5, 0 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *BridgeWithDimerCBTiCBRsCDLi::name() const
{
    static const char value[] = "bridge_with_dimer(cbt: i, cbr: *, cdl: i)";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG

void BridgeWithDimerCBTiCBRsCDLi::find(BridgeWithDimerCDLi *parent)
{
    Atom *anchors[2];
    for (int i = 0; i < 2; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(5) && anchors[1]->is(0))
    {
        if (!anchors[0]->hasRole(BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi, 5) ||
                !anchors[1]->hasRole(BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi, 0))
        {
            create<BridgeWithDimerCBTiCBRsCDLi>(parent);
        }
    }
}

void BridgeWithDimerCBTiCBRsCDLi::findAllTypicalReactions()
{
    BridgeWithDimerToHighBridgeAndDimer::find(this);
}
