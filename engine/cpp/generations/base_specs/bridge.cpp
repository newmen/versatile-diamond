#include "bridge.h"
#include "../handbook.h"
#include "../specific_specs/bridge_ctsi.h"
#include "../specific_specs/high_bridge.h"
#include "methyl_on_bridge.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

void Bridge::find(Atom *anchor)
{
    auto spec = anchor->specByRole(3, BRIDGE);

    if (anchor->is(3))
    {
        if (spec)
        {
            spec->findChildren();
        }
        else
        {
            assert(anchor->lattice());
            if (anchor->lattice()->coords().z == 0) return;

            auto diamond = static_cast<const Diamond *>(anchor->lattice()->crystal());
            auto nbrs = diamond->cross_110(anchor);
            if (nbrs.all() &&
                    nbrs[0]->is(6) && anchor->hasBondWith(nbrs[0]) &&
                    nbrs[1]->is(6) && anchor->hasBondWith(nbrs[1]))
            {
                Atom *atoms[] = { anchor, nbrs[0], nbrs[1] };
                spec = new Bridge(BRIDGE, atoms);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(3, spec);
                nbrs[0]->describe(6, spec);
                nbrs[1]->describe(6, spec);

                spec->findChildren();
            }
        }
    }
    else
    {
        if (spec)
        {
            spec->findChildren();

            anchor->forget(3, spec);
            spec->atom(1)->forget(3, spec);
            spec->atom(2)->forget(3, spec);

            Handbook::scavenger.markSpec<BRIDGE>(spec);
        }
    }
}

void Bridge::findChildren()
{
    MethylOnBridge::find(this);
    HighBridge::find(this);
    BridgeCTsi::find(this);
}


