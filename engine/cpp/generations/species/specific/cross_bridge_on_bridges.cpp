#include "cross_bridge_on_bridges.h"
#include "../base/methyl_on_bridge.h"
#include "../../reactions/typical/serpynsky_drop.h"

const ushort CrossBridgeOnBridges::__indexes[1] = { 0 };
const ushort CrossBridgeOnBridges::__roles[1] = { 10 };

#ifdef PRINT
const char *CrossBridgeOnBriges::name() const
{
    static const char value[] = "cross bridge on briges";
    return value;
}
#endif // PRINT

void CrossBridgeOnBridges::find(Atom *anchor)
{
    if (anchor->is(10))
    {
        if (!anchor->checkAndFind(CROSS_BRIDGE_ON_BRIDGES, 10))
        {
            ParentSpec *first = nullptr, *second = nullptr;

            anchor->eachSpecByRole<MethylOnBridge>(14, [anchor, &first, &second](MethylOnBridge *target) {
                if (!first)
                {
                    first = target;
                }
                else
                {
                    second = target;
                }
            });

            create(first, second);
            create(second, first);
        }
    }
}

void CrossBridgeOnBridges::findAllTypicalReactions()
{
    SerpynskyDrop::find(this);
}

void CrossBridgeOnBridges::create(ParentSpec *first, ParentSpec *second)
{
    ParentSpec *parents[2] = { first, second };
    Creator::create<CrossBridgeOnBridges>(parents);
}
