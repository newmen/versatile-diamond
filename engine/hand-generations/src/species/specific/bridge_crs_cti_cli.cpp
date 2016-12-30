#include "bridge_crs_cti_cli.h"
#include "../../reactions/typical/next_level_bridge_to_high_bridge.h"

template <> const ushort BridgeCRsCTiCLi::Base::__indexes[3] = { 0, 1, 2 };
template <> const ushort BridgeCRsCTiCLi::Base::__roles[3] = { 0, 5, 4 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
const char *BridgeCRsCTiCLi::name() const
{
    static const char value[] = "bridge(cr: *, ct: i, cl: i)";
    return value;
}
#endif // PRINT || SPEC_PRINT || SERIALIZE

void BridgeCRsCTiCLi::find(BridgeCRs *parent)
{
    Atom *anchors[3];
    for (int i = 0; i < 3; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(0) && anchors[1]->is(5) && anchors[2]->is(4))
    {
        if (!anchors[0]->hasRole(BRIDGE_CRs_CTi_CLi, 0) ||
                !anchors[1]->hasRole(BRIDGE_CRs_CTi_CLi, 5) ||
                !anchors[2]->hasRole(BRIDGE_CRs_CTi_CLi, 4))
        {
            create<BridgeCRsCTiCLi>(parent);
        }
    }
}

void BridgeCRsCTiCLi::findAllTypicalReactions()
{
    NextLevelBridgeToHighBridge::find(this);
}
