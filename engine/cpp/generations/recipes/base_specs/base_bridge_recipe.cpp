#include "base_bridge_recipe.h"
#include "base_dimer_recipe.h"

void BaseBridgeRecipe::find(Atom *anchor) const
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
            uint types[3] = { 3, 6, 6 };
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

