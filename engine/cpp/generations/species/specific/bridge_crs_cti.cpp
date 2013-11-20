#include "bridge_crs_cti.h"
#include "../../reactions/typical/next_level_bridge_to_high_bridge.h"

ushort BridgeCRsCTi::__indexes[2] = { 0, 1 };
ushort BridgeCRsCTi::__roles[2] = { 0, 5 };

void BridgeCRsCTi::find(BridgeCRs *parent)
{
    Atom *anchors[2];
    for (int i = 0; i < 2; ++i)
    {
        anchors[i] = parent->atom(__indexes[i]);
    }

    if (anchors[0]->is(0))
    {
        // TODO: there || statement must be used because anchors[0] could have current role in another specie
        // the || statement can be defined through simetry of specie: if has central atom then || (else &&, if atoms num is even)
        if (!anchors[0]->hasRole(0, BRIDGE_CRs_CTi) || !anchors[1]->hasRole(5, BRIDGE_CRs_CTi))
        {
            auto spec = new BridgeCRsCTi(parent);
            spec->store();
        }
    }
}

void BridgeCRsCTi::findAllReactions()
{
    NextLevelBridgeToHighBridge::find(this);
}
