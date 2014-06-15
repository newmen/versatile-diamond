#include "cross_bridge_on_bridges.h"
#include "../base/methyl_on_bridge.h"
#include "../../reactions/typical/sierpinski_drop.h"

const ushort CrossBridgeOnBridges::__indexes[1] = { 0 };
const ushort CrossBridgeOnBridges::__roles[1] = { 10 };

#ifdef PRINT
const char *CrossBridgeOnBridges::name() const
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
            ParentSpec *parents[2] = { nullptr, nullptr };

            anchor->eachSpecByRole<MethylOnBridge>(14, [anchor, &parents](MethylOnBridge *target) {
                if (!parents[0])
                {
                    parents[0] = target;
                }
                else
                {
                    parents[1] = target;
                }
            });

            if (parents[1])
            {
                create<CrossBridgeOnBridges>(parents);
            }
        }
    }
}

void CrossBridgeOnBridges::findAllTypicalReactions()
{
    SierpinskiDrop::find(this);
}
