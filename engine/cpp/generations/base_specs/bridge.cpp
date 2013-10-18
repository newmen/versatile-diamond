#include "bridge.h"
#include "../handbook.h"

void Bridge::find(Atom *anchor)
{
    if (!anchor->is(3)) return;
    if (!anchor->prevIs(3))
    {
        assert(anchor->lattice());
        if (anchor->lattice()->coords().z == 0) return;

        const Diamond *diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->cross_110(anchor);
        if (nbrs.all() && nbrs[0]->is(6) && nbrs[1]->is(6) &&
                anchor->hasBondWith(nbrs[0]) && anchor->hasBondWith(nbrs[1]))
        {
            ushort types[] = { 3, 6, 6 };
            Atom *atoms[] = { anchor, nbrs[0], nbrs[1] };

            auto bridge = new Bridge(BRIDGE, atoms);
            bridge->setupAtomTypes(types);
#pragma omp barrier // only for bridge, because dimer belongs to two bridges
            Handbook::storeBridge(bridge);
        }
        else return;
    }

    findChildren(anchor);
}

void Bridge::findChildren(Atom *anchor)
{
#pragma omp parallel sections
    {
#pragma omp section
        {
            Dimer::find(anchor);
        }
#pragma omp section
        {
//            BridgeCts::find(anchor);
        }
    }
}


