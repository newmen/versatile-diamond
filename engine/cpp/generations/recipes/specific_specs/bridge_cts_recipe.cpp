#include "bridge_cts_recipe.h"

void BridgeCtsRecipe::find(Atom *anchor) const
{
    if (!anchor->is(1)) return;
    if (!anchor->prevIs(1))
    {
        assert(anchor->lattice());

        auto bridgeCts = new BridgeCts(types, atoms);
//        const Diamond *diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
//        assert(diamond);

//        auto nbrs = diamond->cross_110(anchor);
//        if (nbrs.all() && nbrs[0]->is(6) && nbrs[1]->is(6) &&
//                anchor->hasBondWith(nbrs[0]) && anchor->hasBondWith(nbrs[1]))
//        {
//            uint types[3] = { 3, 6, 6 };
//            Atom *atoms[3] = { anchor, nbrs[0], nbrs[1] };

//            auto bridge = new Bridge(types, atoms);
//            Dictionary::storeBridge(bridge);
//        }
//        else return;
    }

//    findChildren(anchor);
}
