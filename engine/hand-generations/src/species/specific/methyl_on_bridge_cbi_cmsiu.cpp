#include "methyl_on_bridge_cbi_cmsiu.h"
#include "../../reactions/typical/migration_down_at_dimer.h"
#include "methyl_on_bridge_cbi_cmssiu.h"
#include "methyl_on_bridge_cbs_cmsiu.h"

template <> const ushort MethylOnBridgeCBiCMsiu::Base::__indexes[1] = { 0 };
template <> const ushort MethylOnBridgeCBiCMsiu::Base::__roles[1] = { 26 };

#ifdef PRINT
const char *MethylOnBridgeCBiCMsiu::name() const
{
    static const char value[] = "methyl_on_bridge(cb: i, cm: *, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnBridgeCBiCMsiu::find(MethylOnBridgeCBiCMiu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(26))
    {
        if (!anchor->checkAndFind(METHYL_ON_BRIDGE_CBi_CMsiu, 26))
        {
            create<MethylOnBridgeCBiCMsiu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMsiu::findAllChildren()
{
    MethylOnBridgeCBiCMssiu::find(this);
    MethylOnBridgeCBsCMsiu::find(this);
}

void MethylOnBridgeCBiCMsiu::findAllTypicalReactions()
{
    MigrationDownAtDimer::find(this);
}
