#include "methyl_on_bridge_cbi_cmssiu.h"
#include "../../reactions/typical/migration_down_in_gap.h"

template <> const ushort MethylOnBridgeCBiCMssiu::Base::__indexes[1] = { 0 };
template <> const ushort MethylOnBridgeCBiCMssiu::Base::__roles[1] = { 27 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
const char *MethylOnBridgeCBiCMssiu::name() const
{
    static const char value[] = "methyl_on_bridge(cb: i, cm: **, cm: i, cm: u)";
    return value;
}
#endif // PRINT || SPEC_PRINT || JSONLOG

void MethylOnBridgeCBiCMssiu::find(MethylOnBridgeCBiCMsiu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(27))
    {
        if (!anchor->hasRole(METHYL_ON_BRIDGE_CBi_CMssiu, 27))
        {
            create<MethylOnBridgeCBiCMssiu>(parent);
        }
    }
}

void MethylOnBridgeCBiCMssiu::findAllTypicalReactions()
{
    MigrationDownInGap::find(this);
}
