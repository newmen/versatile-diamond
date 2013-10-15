#include "base_bridge_recipe.h"
#include "base_dimer_recipe.h"
#include "../dictionary.h"
#include "../crystals/diamond.h"

void BaseBridgeRecipe::find(Atom *anchor) const
{
    if (!anchor->is(0)) return;
    if (!anchor->prevIs(0))
    {
        assert(anchor->lattice());
        if (anchor->lattice()->coords().z == 0) return;

        const Diamond *diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->cross_110(anchor);
        if (nbrs.all() && nbrs[0]->is(1) && nbrs[1]->is(1) &&
                anchor->hasBondWith(nbrs[0]) && anchor->hasBondWith(nbrs[1]))
        {
            uint types[3] = { 0, 1, 1 };
            Atom *atoms[3] = { anchor, nbrs[0], nbrs[1] };

            auto bridge = new Bridge(types, atoms);
            Dictionary::storeBridge(bridge);
        }
        else return;
    }

    findChildren(anchor);
}

void BaseBridgeRecipe::findChildren(Atom *anchor) const
{
//#pragma omp parallel sections
//    {
//#pragma omp section
//        {
            BaseDimerRecipe bdr;
            bdr.find(anchor);
//        }
//#pragma omp section
//        {

//        }
//    }
}

