#include "high_bridge_cms.h"
#include "../../reactions/typical/migration_down_in_gap_from_high_bridge.h"

const ushort HighBridgeCMs::__indexes[1] = { 0 };
const ushort HighBridgeCMs::__roles[1] = { 16 };

#ifdef PRINT
const char *HighBridgeCMs::name() const
{
    static const char value[] = "high_bridge(cm: *)";
    return value;
}
#endif // PRINT

void HighBridgeCMs::find(HighBridge *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(16))
    {
        if (!anchor->hasRole(HIGH_BRIDGE_CMs, 16))
        {
            create<HighBridgeCMs>(parent);
        }
    }
}

void HighBridgeCMs::findAllTypicalReactions()
{
    MigrationDownInGapFromHighBridge::find(this);
}
