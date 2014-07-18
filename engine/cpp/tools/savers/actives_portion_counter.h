#ifndef ACTIVES_PORTION_COUNTER_H
#define ACTIVES_PORTION_COUNTER_H

#include "../../atoms/atom.h"
#include "../common.h"

namespace vd
{

template <class HB>
class ActivesPortionCounter
{
    struct HydroActs
    {
        uint actives, hydrogens;
        HydroActs(uint actives = 0, uint hydrogens = 0) : actives(actives), hydrogens(hydrogens) {}

        void adsorb(const HydroActs &ha)
        {
            actives += ha.actives;
            hydrogens += ha.hydrogens;
        }
    };

public:
    ActivesPortionCounter() {}

    double countFrom(Atom *atom) const;

private:
    ActivesPortionCounter(const ActivesPortionCounter &) = delete;
    ActivesPortionCounter(ActivesPortionCounter &&) = delete;
    ActivesPortionCounter &operator = (const ActivesPortionCounter &) = delete;
    ActivesPortionCounter &operator = (ActivesPortionCounter &&) = delete;

    HydroActs recursiveCount(Atom *atom) const;
};

//////////////////////////////////////////////////////////////////////////////

template <class HB>
double ActivesPortionCounter<HB>::countFrom(Atom *atom) const
{
    HydroActs ha = recursiveCount(atom);
    return (double)ha.actives / (ha.actives + ha.hydrogens);
}

template <class HB>
ActivesPortionCounter<HB>::HydroActs ActivesPortionCounter<HB>::recursiveCount(Atom *atom) const
{
    HydroActs result;
    result.actives += HB::activiesFor(atom);
    result.hydrogens += HB::hydrogensFor(atom);

    atom->setVisited();
    atom->eachNeighbour([this, &result, atom](Atom *nbr) {
        if (!nbr->isVisited())
        {
            result.adsorb(recursiveCount(nbr));
        }
    });

    return result;
}

}

#endif // ACTIVES_PORTION_COUNTER_H
