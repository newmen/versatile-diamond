#include "high_bridge.h"
#include "../handbook.h"
#include "../reactions/typical/high_bridge_stand_to_one_bridge.h"
#include "../reactions/typical/high_bridge_to_two_bridges.h"

void HighBridge::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(19))
    {
        if (!anchor->hasRole(19, HIGH_BRIDGE))
        {
            Atom *amorph = anchor->amorphNeighbour();

            if (amorph->is(18))
            {
                auto spec = new HighBridge(&amorph, HIGH_BRIDGE, parent);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(19, spec);
                amorph->describe(18, spec);

                Handbook::keeper().store<KEE_HIGH_BRIDGE>(spec);
            }
        }
    }
    else
    {
        auto spec = anchor->specificSpecByRole(19, HIGH_BRIDGE);
        if (spec)
        {
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(19, spec);
            spec->atom(0)->forget(18, spec);

            Handbook::scavenger().markSpec<HIGH_BRIDGE>(spec);
        }
    }
}

void HighBridge::findChildren()
{
    HighBridgeStandToOneBridge::find(this);
    HighBridgeToTwoBridges::find(this);
}
