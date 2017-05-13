#include "methyl_on_bridge_cbi_cmiu.h"
#include "../../reactions/typical/des_methyl_from_bridge.h"
#include "methyl_on_bridge_cbi_cmsiu.h"

template <> const ushort MethylOnBridgeCBiCMiu::Base::__indexes[2] = { 1, 0 };
template <> const ushort MethylOnBridgeCBiCMiu::Base::__roles[2] = { 7, 25 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *MethylOnBridgeCBiCMiu::name() const
{
    static const char value[] = "methyl_on_bridge(cb: i, cm: i, cm: u)";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG

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
