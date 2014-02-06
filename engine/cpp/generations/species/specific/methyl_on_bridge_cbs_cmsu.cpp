#include "methyl_on_bridge_cbs_cmsu.h"
#include "../../reactions/typical/form_two_bond.h"

const ushort MethylOnBridgeCBsCMsu::__indexes[1] = { 1 };
const ushort MethylOnBridgeCBsCMsu::__roles[1] = { 8 };

void MethylOnBridgeCBsCMsu::find(MethylOnBridgeCBiCMsu *parent)
{
    Atom *anchor = parent->atom(1);
    if (anchor->is(8))
    {
        if (!anchor->hasRole(METHYL_ON_BRIDGE_CBs_CMsu, 8))
        {
            create<MethylOnBridgeCBsCMsu>(parent);
        }
    }
}

void MethylOnBridgeCBsCMsu::findAllTypicalReactions()
{
    FormTwoBond::find(this);
}
