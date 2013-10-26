#include "bridge.h"
#include "../handbook.h"
#include "../specific_specs/bridge_cts.h"

#include <omp.h>

#ifdef PRINT
#include <iostream>
#endif // PRINT

void Bridge::find(Atom *anchor)
{
    if (!anchor->is(3)) return; // TODO: remove all children?
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
            auto bridge = std::shared_ptr<BaseSpec>(new Bridge(BRIDGE, atoms));

            anchor->describe(3, bridge);
            nbrs[0]->describe(6, bridge);
            nbrs[1]->describe(6, bridge);

#ifdef PRINT
#pragma omp critical
            {
                std::cout << "Bridge at ";
                bridge->info();
                std::cout<< " was found" << std::endl;
            }
#endif // PRINT

            bridge->findChildren();
        }
    }
    else
    {
        anchor->specByRole(3, BRIDGE)->findChildren();
    }
}

void Bridge::findChildren()
{
#pragma omp parallel sections
    {
#pragma omp section
        {
            BridgeCTs::find(this);
        }
//#pragma omp section
//        {
//        }
    }
}


