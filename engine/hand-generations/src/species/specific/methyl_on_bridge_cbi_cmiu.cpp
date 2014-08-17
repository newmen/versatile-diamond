#include "methyl_on_bridge_cbi_cmiu.h"
#include "../../reactions/typical/des_methyl_from_bridge.h"
#include "methyl_on_bridge_cbi_cmsiu.h"

const ushort MethylOnBridgeCBiCMiu::__indexes[2] = { 1, 0 };
const ushort MethylOnBridgeCBiCMiu::__roles[2] = { 7, 25 };

#ifdef PRINT
const char *MethylOnBridgeCBiCMiu::name() const
{
    static const char value[] = "methyl_on_bridge(cb: i, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnBridgeCBiCMiu::find(MethylOnBridge *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(1) };
    if (anchors[0]->is(25) && anchors[1]->is(7))
    {
        if (!anchors[0]->checkAndFind(METHYL_ON_BRIDGE_CBi_CMiu, 25) &&
                !anchors[1]->checkAndFind(METHYL_ON_BRIDGE_CBi_CMiu, 7))
        {
            create<MethylOnBridgeCBiCMiu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMiu::findAllChildren()
{
    MethylOnBridgeCBiCMsiu::find(this);
}

void MethylOnBridgeCBiCMiu::findAllTypicalReactions()
{
    DesMethylFromBridge::find(this);
}
