#include "bridge_with_dimer_cdli.h"
#include "../../reactions/typical/dimer_drop_near_bridge.h"
#include "bridge_with_dimer_cbti_cbrs_cdli.h"

template <> const ushort BridgeWithDimerCDLi::Base::__indexes[1] = { 6 };
template <> const ushort BridgeWithDimerCDLi::Base::__roles[1] = { 20 };

#ifdef PRINT
const char *BridgeWithDimerCDLi::name() const
{
    static const char value[] = "bridge_with_dimer(cdl: i)";
    return value;
}
#endif // PRINT

void BridgeWithDimerCDLi::find(BridgeWithDimer *parent)
{
    Atom *anchor = parent->atom(6);
    assert(anchor->is(22));

    if (anchor->is(20))
    {
        if (!anchor->checkAndFind(BRIDGE_WITH_DIMER_CDLi, 20))
        {
            create<BridgeWithDimerCDLi>(parent);
        }
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
