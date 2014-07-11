#ifndef ACTIVES_PORTION_COUNTER_H
#define ACTIVES_PORTION_COUNTER_H

#include <vector>
#include "../../atoms/atom.h"
#include "../common.h"

namespace vd
{

class ActivesPortionCounter
{
    const std::vector<ushort> _regularAtomTypes;

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
    ActivesPortionCounter(const std::initializer_list<ushort> &regularAtomTypes);

    double countFrom(Atom *atom) const;

private:
    bool isRegular(const Atom *atom) const;
    HydroActs recursiveCount(Atom *atom) const;
};

}

#endif // ACTIVES_PORTION_COUNTER_H
