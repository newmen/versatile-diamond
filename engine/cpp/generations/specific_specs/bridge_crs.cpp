#include "bridge_crs.h"
#include "../handbook.h"
#include "../reactions/typical/next_level_bridge_to_high_bridge.h"
#include "../reactions/typical/high_bridge_to_two_bridges.h"

void BridgeCRs::find(Bridge *parent)
{
    uint indexes[2] = { 1, 2 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(indexes[i]);
        if (anchor->isVisited()) continue; // т.к. нет дочерних структур - выходим тут

        if (anchor->is(5))
        {
            if (!anchor->hasRole(5, BRIDGE_CRs))
            {
                auto spec = new BridgeCRs(indexes[i], 1, BRIDGE_CRs, parent);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(5, spec);
                Handbook::keeper().store<KEE_BRIDGE_CRs>(spec);
            }
        }
        else
        {
            auto spec = anchor->specificSpecByRole(5, BRIDGE_CRs);
            if (spec)
            {
                spec->removeReactions();

#ifdef PRINT
                spec->wasForgotten();
#endif // PRINT

                anchor->forget(5, spec);
                Handbook::scavenger().markSpec<BRIDGE_CRs>(spec);
            }
        }
    }
}

void BridgeCRs::findChildren()
{
    NextLevelBridgeToHighBridge::find(this);
    HighBridgeToTwoBridges::find(this);
}
