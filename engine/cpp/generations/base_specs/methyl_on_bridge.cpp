#include "methyl_on_bridge.h"
#include "../handbook.h"
#include "../specific_specs/methyl_on_bridge_cbi_cmu.h"

void MethylOnBridge::find(Bridge *target)
{
    Atom *anchor = target->atom(0);
    auto spec = anchor->specByRole(9, METHYL_ON_BRIDGE);

    if (anchor->is(9))
    {
        if (spec)
        {
            spec->findChildren();
        }
        else
        {
            Atom *methyl = anchor->amorphNeighbour();

            if (methyl->is(14))
            {
                BaseSpec *parent = target;
                spec = new MethylOnBridge(&methyl, METHYL_ON_BRIDGE, &parent);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(9, spec);
                methyl->describe(14, spec);

                spec->findChildren();
            }
        }
    }
    else
    {
        if (spec)
        {
            spec->findChildren();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(9, spec);
            spec->atom(0)->forget(14, spec);

            Handbook::scavenger.markSpec<METHYL_ON_BRIDGE>(spec);
        }
    }
}

void MethylOnBridge::findChildren()
{
    MethylOnBridgeCBiCMu::find(this);
}
