#include "methyl_on_bridge.h"
#include "../specific/methyl_on_bridge_cbi_cmiu.h"
#include "../specific/methyl_on_111_cmiu.h"

template <> const ushort MethylOnBridge::Base::__indexes[2] = { 1, 0 };
template <> const ushort MethylOnBridge::Base::__roles[2] = { 9, 14 };

#ifdef PRINT
const char *MethylOnBridge::name() const
{
    static const char value[] = "methyl on bridge";
    return value;
}
#endif // PRINT

void MethylOnBridge::find(Bridge *target)
{
    Atom *anchor = target->atom(0);
    if (anchor->is(9))
    {
        if (!anchor->checkAndFind(METHYL_ON_BRIDGE, 9))
        {
            Atom *amorph = anchor->amorphNeighbour();
            if (amorph->is(14))
            {
                create<MethylOnBridge>(amorph, target);
            }
        }
    }
}

void MethylOnBridge::findAllChildren()
{
    MethylOnBridgeCBiCMiu::find(this);
    MethylOn111CMiu::find(this);
}
