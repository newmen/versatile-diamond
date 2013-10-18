#include "dimer.h"
#include "../handbook.h"

#include <omp.h>

void Dimer::find(Atom *anchor)
{
    if (!anchor->is(22)) return;
    if (!anchor->prevIs(22))
    {
        assert(anchor->lattice());

        const Diamond *diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->front_100(anchor);
        if (nbrs[0] && nbrs[0]->is(22) && anchor->hasBondWith(nbrs[0]) && nbrs[0]->hasRole(3, BRIDGE))
        {
            ushort types[2] = { 22, 22 };
            Atom *atoms[2] = { anchor, nbrs[0] };

            auto dimer = new Dimer(DIMER, atoms);
            dimer->setupAtomTypes(types);
            Handbook::storeDimer(dimer);
        }
        else return;
    }

    findChildren(anchor);
}

void Dimer::findChildren(Atom *anchor)
{

}

