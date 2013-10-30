#include "bridge.h"
#include "../handbook.h"
#include "../specific_specs/bridge_ctsi.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

void Bridge::find(Atom *anchor)
{
    if (anchor->is(3))
    {
        if (!anchor->prevIs(3))
        {
            assert(anchor->lattice());
            if (anchor->lattice()->coords().z == 0) return;

            auto diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
            assert(diamond);

            auto nbrs = diamond->cross_110(anchor);
            if (nbrs.all() &&
                    nbrs[0]->is(6) && anchor->hasBondWith(nbrs[0]) &&
                    nbrs[1]->is(6) && anchor->hasBondWith(nbrs[1]))
            {
                Atom *atoms[] = { anchor, nbrs[0], nbrs[1] };
                auto spec = std::shared_ptr<BaseSpec>(new Bridge(BRIDGE, atoms));

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(3, spec);
                nbrs[0]->describe(6, spec);
                nbrs[1]->describe(6, spec);

                spec->findChildren();
            }
        }
        else if (anchor->hasRole(3, BRIDGE))
        {
            anchor->specByRole(3, BRIDGE)->findChildren();
        }
    }
    else if (anchor->hasRole(3, BRIDGE))
    {
        anchor->specByRole(3, BRIDGE)->findChildren();
        anchor->forget(3, BRIDGE);
    }
}

void Bridge::findChildren()
{
#ifdef PARALLEL
//#pragma omp parallel sections
//    {
//#pragma omp section
//        {
#endif // PARALLEL
            BridgeCTsi::find(this);
#ifdef PARALLEL
//        }
//#pragma omp section
//        {
//        }
//    }
#endif // PARALLEL
}


