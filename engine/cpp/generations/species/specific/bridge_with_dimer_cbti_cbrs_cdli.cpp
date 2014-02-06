#include "bridge_with_dimer_cbti_cbrs_cdli.h"
#include "../../reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h"

const ushort BridgeWithDimerCBTiCBRsCDLi::__indexes[2] = { 3, 4 };
const ushort BridgeWithDimerCBTiCBRsCDLi::__roles[2] = { 0, 5 };

#ifdef PRINT
const char *BridgeWithDimerCBTiCBRsCDLi::name() const
{
    static const char value[] = "bridge_with_dimer(cbt: i, cbr: *, cdl: i)";
    return value;
}
#endif // PRINT

void BridgeWithDimerCBTiCBRsCDLi::find(BridgeWithDimerCDLi *parent)
{
    Atom *anchor = parent->atom(3);
    if (anchor->is(0) && parent->atom(4)->is(5))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi, 0))
        {
            create<BridgeWithDimerCBTiCBRsCDLi>(parent);
        }
    }
}

void BridgeWithDimerCBTiCBRsCDLi::findAllTypicalReactions()
{
    BridgeWithDimerToHighBridgeAndDimer::find(this);
}
