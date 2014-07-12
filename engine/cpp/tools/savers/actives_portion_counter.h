#ifndef ACTIVES_PORTION_COUNTER_H
#define ACTIVES_PORTION_COUNTER_H

#include "../../atoms/atom.h"
#include "../common.h"

namespace vd
{

class ActivesPortionCounter
{
    struct HydroActs
    {
        uint actives, hydrogens;
        HydroActs(uint actives = 0, uint hydrogens = 0) : actives(actives), hydrogens(hydrogens) {}

        void adsort(const HydroActs &ha)
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

    bool isBottom(const Atom *atom) const;
    HydroActs recursiveCount(Atom *atom) const;
};

}

#endif // ACTIVES_PORTION_COUNTER_H
