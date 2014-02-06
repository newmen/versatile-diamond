#include "methyl_on_bridge_cbi_cmu.h"
#include "../../reactions/typical/des_methyl_from_bridge.h"
#include "methyl_on_bridge_cbi_cmsu.h"

const ushort MethylOnBridgeCBiCMu::__indexes[2] = { 1, 0 };
const ushort MethylOnBridgeCBiCMu::__roles[2] = { 7, 25 };

void MethylOnBridgeCBiCMu::find(MethylOnBridge *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(1) };
    if (anchors[0]->is(25) && anchors[1]->is(7))
    {
        if (!anchors[0]->hasRole(METHYL_ON_BRIDGE_CBi_CMu, 25) && !anchors[1]->hasRole(METHYL_ON_BRIDGE_CBi_CMu, 7))
        {
            create<MethylOnBridgeCBiCMu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMu::findAllChildren()
{
    MethylOnBridgeCBiCMsu::find(this);
}

void MethylOnBridgeCBiCMu::findAllTypicalReactions()
{
    DesMethylFromBridge::find(this);
}
