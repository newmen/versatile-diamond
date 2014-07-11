#include "actives_portion_counter.h"

namespace vd
{

ActivesPortionCounter::ActivesPortionCounter(const std::initializer_list<ushort> &regularAtomTypes) : _regularAtomTypes(regularAtomTypes)
{
}

double ActivesPortionCounter::countFrom(Atom *atom) const
{
    HydroActs ha = recursiveCount(atom);
    return (double)ha.actives / (ha.actives + ha.hydrogens);
}

bool ActivesPortionCounter::isRegular(const Atom *atom) const
{
    bool result = false;
    for (ushort type : _regularAtomTypes)
    {
        result = atom->is(type);
        if (result) break;
    }

    return result;
}

ActivesPortionCounter::HydroActs ActivesPortionCounter::recursiveCount(Atom *atom) const
{
    HydroActs result;
    if (!isRegular(atom))
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
