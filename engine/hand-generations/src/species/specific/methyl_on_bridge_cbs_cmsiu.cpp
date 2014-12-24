#include "methyl_on_bridge_cbs_cmsiu.h"
#include "../../reactions/typical/form_two_bond.h"

template <> const ushort MethylOnBridgeCBsCMsiu::Base::__indexes[1] = { 1 };
template <> const ushort MethylOnBridgeCBsCMsiu::Base::__roles[1] = { 8 };

#ifdef PRINT
const char *MethylOnBridgeCBsCMsiu::name() const
{
    static const char value[] = "methyl_on_bridge(cb: s, cm: *, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOnBridgeCBsCMsiu::find(MethylOnBridgeCBiCMsiu *parent)
{
    Atom *anchor = parent->atom(1);
    if (anchor->is(8))
    {
        if (!anchor->hasRole(METHYL_ON_BRIDGE_CBs_CMsiu, 8))
        {
            create<MethylOnBridgeCBsCMsiu>(parent);
        }
    }
}

void MethylOnBridgeCBsCMsiu::findAllTypicalReactions()
{
    FormTwoBond::find(this);
}
