#include "actives_portion_counter.h"

namespace vd
{

double ActivesPortionCounter::countFrom(Atom *atom) const
{
    HydroActs ha = recursiveCount(atom);
    return (double)ha.actives / (ha.actives + ha.hydrogens);
}

bool ActivesPortionCounter::isBottom(const Atom *atom) const
{
    return atom->lattice() && atom->lattice()->coords().z == 0;
}

ActivesPortionCounter::HydroActs ActivesPortionCounter::recursiveCount(Atom *atom) const
{
    HydroActs result;
    if (!isBottom(atom))
    {
        result.actives += atom->actives();
        result.hydrogens += atom->hCount();
    }

    atom->setVisited();
    atom->eachNeighbour([this, &result, atom](Atom *nbr) {
        if (!nbr->isVisited())
        {
            result.adsort(recursiveCount(nbr));
        }
    });

    return result;
}

}
