#include "bridge_crs_cti_cli.h"
#include "../../reactions/typical/next_level_bridge_to_high_bridge.h"

ushort BridgeCRsCTiCLi::__indexes[3] = { 0, 1, 2 };
ushort BridgeCRsCTiCLi::__roles[3] = { 0, 5, 4 };

void BridgeCRsCTiCLi::find(BridgeCRs *parent)
{
    Atom *anchors[3];
    for (int i = 0; i < 3; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(0) && anchors[1]->is(5) && anchors[2]->is(4))
    {
        // TODO: there || statement must be used because anchors[0] could have current role in another specie
        // the || statement can be defined through simetry of specie: if has central atom then || (else &&, if atoms num is even)
        if (!anchors[0]->hasRole(0, BRIDGE_CRs_CTi_CLi) || !anchors[1]->hasRole(5, BRIDGE_CRs_CTi_CLi) ||
                !anchors[2]->hasRole(4, BRIDGE_CRs_CTi_CLi))
        {
            createBy<BridgeCRsCTiCLi>(parent);
        }
    }
}

void BridgeCRsCTiCLi::findAllReactions()
{
    NextLevelBridgeToHighBridge::find(this);
}
