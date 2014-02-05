#include "two_bridges.h"
#include "../dolls/swapped_bridge.h"
#include "../specific/two_bridges_ctri_cbrs.h"

void TwoBridges::find(Atom *anchor)
{
    if (anchor->is(24) && anchor->lattice()->coords().z > 0)
    {
        ParentSpec *topBridges[2];
        ushort index = 0;

        anchor->eachSpecByRole<Bridge>(6, [anchor, &topBridges, &index](Bridge *target) {
            if (target->atom(2) == anchor)
            {
                topBridges[index] = target;
            }
            else
            {
                topBridges[index] = create<SwappedBridge>(target);
            }
            ++index;
        });

        for (uint i = 0; i < 2; ++i)
        {
            uint o = 1 - i;
            ParentSpec *targets[3] = {
                topBridges[i]->atom(1)->specByRole<Bridge>(3),
                topBridges[i],
                topBridges[o]
            };

            create<TwoBridges>(targets);
        }
    }
}

void TwoBridges::findAllChildren()
{
    TwoBridgesCTRiCBRs::find(this);
}
