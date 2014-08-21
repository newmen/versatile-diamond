#include "high_bridge.h"
#include "../../reactions/typical/high_bridge_stand_to_one_bridge.h"
#include "../../reactions/typical/high_bridge_to_two_bridges.h"
#include "../../reactions/typical/high_bridge_stand_to_dimer.h"
#include "../../reactions/typical/high_bridge_to_methyl.h"
#include "../../reactions/typical/migration_down_at_dimer_from_high_bridge.h"
#include "high_bridge_cms.h"

const ushort HighBridge::Base::__indexes[2] = { 1, 0 };
const ushort HighBridge::Base::__roles[2] = { 19, 18 };

#ifdef PRINT
const char *HighBridge::name() const
{
    static const char value[] = "high bridge";
    return value;
}
#endif // PRINT

void HighBridge::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(19))
    {
        if (!anchor->checkAndFind(HIGH_BRIDGE, 19))
        {
            Atom *amorph = anchor->amorphNeighbour();
            if (amorph->is(18))
            {
                create<HighBridge>(amorph, parent);
            }
        }
    }
}

void HighBridge::findAllChildren()
{
    HighBridgeCMs::find(this);
}

void HighBridge::findAllTypicalReactions()
{
    HighBridgeStandToOneBridge::find(this);
    HighBridgeToTwoBridges::find(this);
    HighBridgeStandToDimer::find(this);
    HighBridgeToMethyl::find(this);
    MigrationDownAtDimerFromHighBridge::find(this);
}
