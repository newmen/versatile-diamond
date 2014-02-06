#include "methyl_on_bridge_cbi_cmssu.h"
#include "../../reactions/typical/migration_down_in_gap.h"

const ushort MethylOnBridgeCBiCMssu::__indexes[1] = { 0 };
const ushort MethylOnBridgeCBiCMssu::__roles[1] = { 27 };

void MethylOnBridgeCBiCMssu::find(MethylOnBridgeCBiCMsu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(27))
    {
        if (!anchor->hasRole(METHYL_ON_BRIDGE_CBi_CMssu, 27))
        {
            create<MethylOnBridgeCBiCMssu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMssu::findAllTypicalReactions()
{
    MigrationDownInGap::find(this);
}
