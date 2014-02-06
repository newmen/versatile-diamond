#include "methyl_on_bridge_cbi_cmsu.h"
#include "../../reactions/typical/migration_down_at_dimer.h"
#include "methyl_on_bridge_cbi_cmssu.h"
#include "methyl_on_bridge_cbs_cmsu.h"

const ushort MethylOnBridgeCBiCMsu::__indexes[1] = { 0 };
const ushort MethylOnBridgeCBiCMsu::__roles[1] = { 26 };

#ifdef PRINT
const char *MethylOnBridgeCBiCMsu::name() const
{
    static const char value[] = "methyl_on_bridge(cb: i, cm: *, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnBridgeCBiCMsu::find(MethylOnBridgeCBiCMu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(26))
    {
        if (!anchor->hasRole(METHYL_ON_BRIDGE_CBi_CMsu, 26))
        {
            create<MethylOnBridgeCBiCMsu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMsu::findAllChildren()
{
//    MethylOnBridgeCBiCMssu::find(this); // DISABLED: MigrationDownInGap
    MethylOnBridgeCBsCMsu::find(this);
}

void MethylOnBridgeCBiCMsu::findAllTypicalReactions()
{
//    MigrationDownAtDimer::find(this); // DISABLED
}
