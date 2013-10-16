#include "base_dimer_recipe.h"

#include <omp.h>

void BaseDimerRecipe::find(Atom *anchor) const
{
    if (!anchor->is(22)) return;
    if (!anchor->prevIs(22))
    {
        assert(anchor->lattice());

        const Diamond *diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->front_100(anchor);
        if (nbrs[0] && nbrs[0]->is(22) && anchor->hasBondWith(nbrs[0]))
        {
            uint types[3] = { 22, 22 };
            Atom *atoms[3] = { anchor, nbrs[0] };

            auto dimer = new Dimer(types, atoms);
            Dictionary::storeDimer(dimer);
        }
        else return;
    }

    findChildren(anchor);
}

void BaseDimerRecipe::findChildren(Atom *anchor) const
{

}
