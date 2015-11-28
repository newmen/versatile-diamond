#include "bridge_ctsi.h"
#include "../../reactions/central/dimer_formation.h"
#include "../../reactions/typical/dimer_formation_near_bridge.h"
#include "../../reactions/typical/high_bridge_stand_to_one_bridge.h"
#include "../../reactions/typical/high_bridge_to_methyl.h"

template <> const ushort BridgeCTsi::Base::__indexes[1] = { 0 };
template <> const ushort BridgeCTsi::Base::__roles[1] = { 28 };

#ifdef PRINT
const char *BridgeCTsi::name() const
{
    static const char value[] = "bridge(ct: *, ct: i)";
    return value;
}
#endif // PRINT

void BridgeCTsi::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(28))
    {
        if (!anchor->hasRole(BRIDGE_CTsi, 28))
        {
            create<BridgeCTsi>(parent);
        }
    }
}

void BridgeCTsi::findAllTypicalReactions()
{
    DimerFormation::find(this);
    DimerFormationNearBridge::find(this);
    HighBridgeStandToOneBridge::find(this);
    HighBridgeToMethyl::find(this);
}
