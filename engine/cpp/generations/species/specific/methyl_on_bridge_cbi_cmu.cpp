#include "methyl_on_bridge_cbi_cmu.h"
#include "../../reactions/typical/des_methyl_from_bridge.h"

ushort MethylOnBridgeCBiCMu::__indexes[2] = { 1, 0 };
ushort MethylOnBridgeCBiCMu::__roles[2] = { 7, 25 };

void MethylOnBridgeCBiCMu::find(MethylOnBridge *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(1) };

    if (anchors[0]->is(25) && anchors[1]->is(7))
    {
        if (!anchors[0]->hasRole(25, METHYL_ON_BRIDGE_CBi_CMu) && !anchors[1]->hasRole(7, METHYL_ON_BRIDGE_CBi_CMu))
        {
            createBy<MethylOnBridgeCBiCMu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMu::findAllReactions()
{
    DesMethylFromBridge::find(this);
}
